BLOCK-LEVEL ON ERROR UNDO, THROW.

/*----------------------------------------------------------------------------
  import-cobrand-koder.p

  Imports cobrand codes from column C in a CSV file into the koder table.

  Usage:
    RUN import-cobrand-koder.p (INPUT "C:\temp\cobrands.csv").

  Notes:
    - If the input parameter is blank or ?, SESSION:PARAMETER is used.
    - If neither is set, the default file is sample-cobrand-koder.csv.
    - The procedure auto-detects "," versus ";" per line.
    - The first row is treated as a header when column C is not an integer.
----------------------------------------------------------------------------*/

DEFINE INPUT PARAMETER pcFile AS CHARACTER NO-UNDO.

DEFINE VARIABLE cFile           AS CHARACTER NO-UNDO.
DEFINE VARIABLE cLine           AS CHARACTER NO-UNDO.
DEFINE VARIABLE cCodeValue      AS CHARACTER NO-UNDO.
DEFINE VARIABLE cDelimiter      AS CHARACTER NO-UNDO.
DEFINE VARIABLE iCodeNr         AS INTEGER   NO-UNDO.
DEFINE VARIABLE iLinesRead      AS INTEGER   NO-UNDO.
DEFINE VARIABLE iSkipped        AS INTEGER   NO-UNDO.
DEFINE VARIABLE iExisting       AS INTEGER   NO-UNDO.
DEFINE VARIABLE iCreated        AS INTEGER   NO-UNDO.
DEFINE VARIABLE iHeaderSkipped  AS INTEGER   NO-UNDO.
DEFINE VARIABLE lCreated        AS LOGICAL   NO-UNDO.
DEFINE VARIABLE lExisting       AS LOGICAL   NO-UNDO.

FUNCTION fCleanField RETURNS CHARACTER
  ( INPUT pcValue AS CHARACTER ):
  DEFINE VARIABLE cValue AS CHARACTER NO-UNDO.

  ASSIGN cValue = TRIM(pcValue).

  IF LENGTH(cValue) >= 2
  AND SUBSTRING(cValue, 1, 1) = '"'
  AND SUBSTRING(cValue, LENGTH(cValue), 1) = '"' THEN
    cValue = SUBSTRING(cValue, 2, LENGTH(cValue) - 2).

  RETURN TRIM(REPLACE(cValue, '""', '"')).
END FUNCTION.

FUNCTION fGetDelimiter RETURNS CHARACTER
  ( INPUT pcLine AS CHARACTER ):
  DEFINE VARIABLE iIndex   AS INTEGER   NO-UNDO.
  DEFINE VARIABLE iCommas  AS INTEGER   NO-UNDO.
  DEFINE VARIABLE iSemis   AS INTEGER   NO-UNDO.
  DEFINE VARIABLE cChar    AS CHARACTER NO-UNDO.
  DEFINE VARIABLE lInQuotes AS LOGICAL  NO-UNDO.

  DO iIndex = 1 TO LENGTH(pcLine):
    ASSIGN cChar = SUBSTRING(pcLine, iIndex, 1).

    IF cChar = '"' THEN DO:
      lInQuotes = NOT lInQuotes.
      NEXT.
    END.

    IF NOT lInQuotes
    AND cChar = "," THEN
      iCommas = iCommas + 1.
    ELSE IF NOT lInQuotes
    AND cChar = ";" THEN
      iSemis = iSemis + 1.
  END.

  IF iSemis > iCommas THEN
    RETURN ";".

  RETURN ",".
END FUNCTION.

FUNCTION fGetColumn RETURNS CHARACTER
  ( INPUT pcLine      AS CHARACTER,
    INPUT pcDelimiter AS CHARACTER,
    INPUT piColumn    AS INTEGER ):
  DEFINE VARIABLE iIndex         AS INTEGER   NO-UNDO.
  DEFINE VARIABLE iLength        AS INTEGER   NO-UNDO.
  DEFINE VARIABLE iCurrentColumn AS INTEGER   NO-UNDO INITIAL 1.
  DEFINE VARIABLE cChar          AS CHARACTER NO-UNDO.
  DEFINE VARIABLE cValue         AS CHARACTER NO-UNDO.
  DEFINE VARIABLE lInQuotes      AS LOGICAL   NO-UNDO.

  ASSIGN
    iIndex  = 1
    iLength = LENGTH(pcLine).

  DO WHILE iIndex <= iLength:
    ASSIGN cChar = SUBSTRING(pcLine, iIndex, 1).

    IF cChar = '"' THEN DO:
      IF lInQuotes
      AND iIndex < iLength
      AND SUBSTRING(pcLine, iIndex + 1, 1) = '"' THEN DO:
        IF iCurrentColumn = piColumn THEN
          cValue = cValue + '"'.

        iIndex = iIndex + 2.
        NEXT.
      END.

      lInQuotes = NOT lInQuotes.
      iIndex = iIndex + 1.
      NEXT.
    END.

    IF NOT lInQuotes
    AND cChar = pcDelimiter THEN DO:
      IF iCurrentColumn = piColumn THEN
        RETURN cValue.

      iCurrentColumn = iCurrentColumn + 1.
      iIndex = iIndex + 1.
      NEXT.
    END.

    IF iCurrentColumn = piColumn THEN
      cValue = cValue + cChar.

    iIndex = iIndex + 1.
  END.

  IF iCurrentColumn = piColumn THEN
    RETURN cValue.

  RETURN "".
END FUNCTION.

FUNCTION fIsInteger RETURNS LOGICAL
  ( INPUT pcValue AS CHARACTER ):
  DEFINE VARIABLE cValue   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE cChar    AS CHARACTER NO-UNDO.
  DEFINE VARIABLE iIndex   AS INTEGER   NO-UNDO.
  DEFINE VARIABLE iStart   AS INTEGER   NO-UNDO INITIAL 1.
  DEFINE VARIABLE iParsed  AS INTEGER   NO-UNDO.

  ASSIGN cValue = fCleanField(pcValue).

  IF cValue = "" THEN
    RETURN FALSE.

  ASSIGN cChar = SUBSTRING(cValue, 1, 1).

  IF cChar = "+"
  OR cChar = "-" THEN DO:
    IF LENGTH(cValue) = 1 THEN
      RETURN FALSE.

    iStart = 2.
  END.

  DO iIndex = iStart TO LENGTH(cValue):
    ASSIGN cChar = SUBSTRING(cValue, iIndex, 1).

    IF INDEX("0123456789", cChar) = 0 THEN
      RETURN FALSE.
  END.

  ASSIGN iParsed = INTEGER(cValue) NO-ERROR.

  IF ERROR-STATUS:ERROR THEN
    RETURN FALSE.

  RETURN TRUE.
END FUNCTION.

ASSIGN cFile = TRIM(IF pcFile = ? THEN "" ELSE pcFile).

IF cFile = "" THEN
  cFile = TRIM(IF SESSION:PARAMETER = ? THEN "" ELSE SESSION:PARAMETER).

IF cFile = "" THEN
  cFile = "sample-cobrand-koder.csv".

PUT UNFORMATTED SUBSTITUTE("Reading cobrand import file: &1", cFile) SKIP.

DO ON ERROR UNDO, THROW:
  INPUT FROM VALUE(cFile).

  REPEAT:
    IMPORT UNFORMATTED cLine NO-ERROR.

    IF ERROR-STATUS:ERROR THEN DO:
      IF ERROR-STATUS:NUM-MESSAGES > 0 THEN
        PUT UNFORMATTED "Stopping import because a read error occurred." SKIP.

      LEAVE.
    END.

    iLinesRead = iLinesRead + 1.

    ASSIGN
      cDelimiter = fGetDelimiter(cLine)
      cCodeValue = fCleanField(fGetColumn(cLine, cDelimiter, 3)).

    IF iLinesRead = 1
    AND NOT fIsInteger(cCodeValue) THEN DO:
      iSkipped = iSkipped + 1.

      IF CAPS(cCodeValue) = "COBRANDCODE"
      OR CAPS(cCodeValue) = "CODENR" THEN DO:
        iHeaderSkipped = iHeaderSkipped + 1.
        PUT UNFORMATTED "Skipping header row." SKIP.
      END.
      ELSE
        PUT UNFORMATTED
          "Skipping first row because column C is not an integer."
          SKIP.

      NEXT.
    END.

    IF NOT fIsInteger(cCodeValue) THEN DO:
      iSkipped = iSkipped + 1.
      PUT UNFORMATTED
        SUBSTITUTE("Skipping line &1: column C is missing or not an integer [&2].",
                   iLinesRead,
                   cCodeValue)
        SKIP.
      NEXT.
    END.

    ASSIGN iCodeNr = INTEGER(cCodeValue) NO-ERROR.

    IF ERROR-STATUS:ERROR THEN DO:
      iSkipped = iSkipped + 1.
      PUT UNFORMATTED
        SUBSTITUTE("Skipping line &1: failed to convert column C [&2].",
                   iLinesRead,
                   cCodeValue)
        SKIP.
      NEXT.
    END.

    ASSIGN
      lCreated  = FALSE
      lExisting = FALSE.

    DO TRANSACTION:
      FIND FIRST koder
           WHERE koder.kodetype = "cobrand"
             AND koder.kodenr   = iCodeNr
           EXCLUSIVE-LOCK NO-ERROR.

      IF AVAILABLE koder THEN
        lExisting = TRUE.
      ELSE DO:
        CREATE koder NO-ERROR.

        IF NOT ERROR-STATUS:ERROR THEN DO:
          ASSIGN
            koder.kodetype = "cobrand"
            koder.kodenr   = iCodeNr
            NO-ERROR.

          IF ERROR-STATUS:ERROR THEN
            UNDO, LEAVE.

          VALIDATE koder NO-ERROR.

          IF ERROR-STATUS:ERROR THEN
            UNDO, LEAVE.

          lCreated = TRUE.
        END.
      END.
    END.

    IF NOT lCreated
    AND NOT lExisting THEN DO:
      FIND FIRST koder
           WHERE koder.kodetype = "cobrand"
             AND koder.kodenr   = iCodeNr
           NO-LOCK NO-ERROR.

      IF AVAILABLE koder THEN
        lExisting = TRUE.
    END.

    IF lExisting THEN
      iExisting = iExisting + 1.
    ELSE IF lCreated THEN DO:
      iCreated = iCreated + 1.
      PUT UNFORMATTED SUBSTITUTE("Created cobrand koder &1.", iCodeNr) SKIP.
    END.
    ELSE DO:
      iSkipped = iSkipped + 1.
      PUT UNFORMATTED
        SUBSTITUTE("Skipping line &1: failed to create koder row for [&2].",
                   iLinesRead,
                   cCodeValue)
        SKIP.
    END.
  END.
CATCH err AS Progress.Lang.Error:
  UNDO, THROW err.
END CATCH.
FINALLY:
  INPUT CLOSE.

  PUT UNFORMATTED SKIP
    SUBSTITUTE("Lines read      : &1", iLinesRead) SKIP
    SUBSTITUTE("Skipped         : &1", iSkipped) SKIP
    SUBSTITUTE("  headers found : &1", iHeaderSkipped) SKIP
    SUBSTITUTE("Existing rows   : &1", iExisting) SKIP
    SUBSTITUTE("New rows created: &1", iCreated) SKIP.
END FINALLY.
END.
