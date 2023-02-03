class ActiveModel
  class EachValidator < Struct.new(:options); end
end
class Record < Struct.new(:errors)
end
class Errors < Struct.new(:list)
  def add(*args)
    list << args
  end
end
