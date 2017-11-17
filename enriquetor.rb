#!/usr/bin/ruby

Dir[__dir__ + "/bullshit/**/*.rb"].each {|file| require file }
Dir[__dir__ + "/slack/**/*.rb"].each {|file| require file }
Dir[__dir__ + "/virtual_enrique/**/*.rb"].each {|file| require file }

class Enriquetor
  class << self
    def get_reply(user = { name: nil })
      case user.name
      when /davide\.dippolito/ then
        reply = italian(user)
      else
        reply = bullshit(user)
      end

      reply.instance_of?(String) ? Typer.add_typing("<@#{user.id}> #{reply}") : reply
    end

    def italian(user)
      [{ text: '`...italian speaker detected, switching to hand-gestures interface...`', typing_seconds: 0.0 },
       { text: "<@#{user.id}> http://cdn.socawlege.com/wp-content/uploads/2015/12/ba62771308457417a7cbdda51e0ea134.gif", typing_seconds: 3.0 }]
    end

    def promotion(user)
      reply = 'you should vote for option 1 in the t-shirt competition'

      "#{VirtualEnrique::Translator.translate(reply)} https://docs.google.com/forms/d/e/1FAIpQLSef93Vy_9Hw3cJBqEr53j_hePvnh3UGIpc6Od3W-j2N2-o3fQ/viewform"
    end

    def bullshit(user)
      reply = Bullshit::Generator.produce
      VirtualEnrique::Translator.translate(reply)
    end
  end
end


if __FILE__ == $0
  Enriquetor.get_reply.each do |line|
    print "Enrique is typing..."
    sleep(line[:typing_seconds])
    print "\r                    \r"
    puts "@enrique: " + line[:text] + "\n"
  end
end

