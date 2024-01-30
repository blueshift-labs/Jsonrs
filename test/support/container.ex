defmodule JsonrsTest.Container do
  @derive Jsonrs.Encoder
  defstruct [:payload]
end
