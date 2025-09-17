defmodule QrcodeTest do
  use ExUnit.Case
  doctest Qrcode

  test "greets the world" do
    assert Qrcode.hello() == :world
  end
end
