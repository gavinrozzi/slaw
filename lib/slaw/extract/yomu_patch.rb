require 'yomu'

class Yomu
  def self.text_from_file(filename)
    IO.popen("#{java} -Djava.awt.headless=true -jar #{Yomu::JARPATH} -t '#{filename}'", 'r') do |io|
      io.read
    end
  end
end
