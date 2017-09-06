#!/usr/bin/ruby

Dir[__dir__ + "/*/**/*.rb"].each {|file| require file }

class Enriquetor
  def self.message(username = nil)
    message = Bullshit::Generator.produce
    translated_message = VirtualEnrique::Translator.translate(message)

    Typer.add_typing([username, translated_message].join(' '))
  end
end


if __FILE__ == $0
  Enriquetor.message.each do |line|
    print "Enrique is typing..."
    sleep(line[:typing_millis] / 1000.0)
    print "\r                    \r"
    puts "@enrique: " + line[:text] + "\n"
  end
end

