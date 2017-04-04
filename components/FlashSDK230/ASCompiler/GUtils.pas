unit GUtils;

interface

uses
  SysUtils;

const
  NF_IND = Low(Integer);

type
  EVectorRangeError = class(Exception)
  public
    ErrInd: Integer;
  end;

  EDictKeyNotFound = class(Exception);

  TRbNodeColor = (ncBlack, ncRed);

implementation

end.
