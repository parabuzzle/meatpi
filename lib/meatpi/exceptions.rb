module MeatPi

  # Top level MeatPi exception (rescue MeatPi::Exception)
  class Exception < Exception
  end

  # GPIO specific exception
  class GPIOException < MeatPi::Exception
  end

end
