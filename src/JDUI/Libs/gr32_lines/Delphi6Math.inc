
  function Cosecant(const X: Extended): Extended;
  { Cosecant := 1 / Sin(X) }
  asm
          FLD   X
          FSIN
          FLD1
          FDIVRP
          FWAIT
  end;

  function Sign(const AValue: Integer): TValueSign; overload;
  begin
    Result := ZeroValue;
    if AValue < 0 then
      Result := NegativeValue
    else if AValue > 0 then
      Result := PositiveValue;
  end;

  function Sign(const AValue: Int64): TValueSign; overload;
  begin
    Result := ZeroValue;
    if AValue < 0 then
      Result := NegativeValue
    else if AValue > 0 then
      Result := PositiveValue;
  end;

  function Sign(const AValue: Double): TValueSign; overload;
  begin
    if ((PInt64(@AValue)^ and $7FFFFFFFFFFFFFFF) = $0000000000000000) then
      Result := ZeroValue
    else if ((PInt64(@AValue)^ and $8000000000000000) = $8000000000000000)
  then
      Result := NegativeValue
    else
      Result := PositiveValue;
  end;
