class Card
  attr_accessor :array_of_raw_cards, :clean_cards

  def initialize(array_of_raw_cards)
    @array_of_raw_cards = array_of_raw_cards
    @clean_cards = set_clean_cards()
  end

  def set_clean_cards
    clean_cards_arr = Array.new()

    @array_of_raw_cards.each do |raw_card|
      raw_card["entities"].each do |card|
        clean_cards_arr << {cardId: card["cardId"], name: card["name"], archived: card["archived"], tags: card["tags"], detailedDescription: card["detailedDescription"]}
      end
    end

    return clean_cards_arr
  end

  def show_clean_cards
    counter=1
    @clean_cards.each do |card|
      puts "#{counter} - cardId : #{card[:cardId]}, name : #{card[:name]}, archived : #{card[:archived]}, tags : #{card[:tags]}, detailedDescription : #{card[:detailedDescription]}"
      counter+=1
    end
  end

  def show_clean_archived_cards
    counter=1
    @clean_cards.each do |card|
      if card[:archived] == true
        puts "#{counter} - cardId : #{card[:cardId]}, name : #{card[:name]}, archived : #{card[:archived]}, tags : #{card[:tags]}, detailedDescription : #{card[:detailedDescription]}"
        counter+=1
      end
    end
  end

  # predict tag from title, check if tag is already exist

  # focused_tags = ["x8KkCFwrAW5jqc7Gx", "Y4Gg9AkZKYJAFspTg", "Hfi25ss7PqBKvHYkQ", "gL2zE25boAyq6moCk", "ioyeWTeuj93m3otbj"]

  def translate_focused_tag(focused_tag)
    case focused_tag
      when "x8KkCFwrAW5jqc7Gx"
        return "SETUP"
      when "Y4Gg9AkZKYJAFspTg"
        return "ACCESS"
      when "Hfi25ss7PqBKvHYkQ"
        return "VPN"
      when "ioyeWTeuj93m3otbj"
        return "VM"
      when "gL2zE25boAyq6moCk"
        return "SSH"
      end
  end

  def tag_checking
    suitable_tags = []
    focused_tags = ["x8KkCFwrAW5jqc7Gx", "Y4Gg9AkZKYJAFspTg", "Hfi25ss7PqBKvHYkQ", "gL2zE25boAyq6moCk", "ioyeWTeuj93m3otbj"]

    counter=1
    @clean_cards.each do |card|
      if card[:archived] == true
        # we will use hardcode for a while

        # x8KkCFwrAW5jqc7Gx, name : SETUP
        # Y4Gg9AkZKYJAFspTg, name : ACCESS
        # Hfi25ss7PqBKvHYkQ, name : VPN
        # gL2zE25boAyq6moCk, name : SSH
        # ioyeWTeuj93m3otbj, name : VM

        # predict suitable tag based on card's name
        unless card[:name].nil?
          suitable_tags << "x8KkCFwrAW5jqc7Gx" if card[:name].downcase.include? "setup"
          suitable_tags << "Y4Gg9AkZKYJAFspTg" if card[:name].downcase.include? "access"
          suitable_tags << "Hfi25ss7PqBKvHYkQ" << "x8KkCFwrAW5jqc7Gx" if card[:name].downcase.include? "vpn"
          suitable_tags << "gL2zE25boAyq6moCk" << "x8KkCFwrAW5jqc7Gx" if card[:name].downcase.include? "ssh"
          suitable_tags << "ioyeWTeuj93m3otbj" << "x8KkCFwrAW5jqc7Gx" if ["box", "ec2", "provision", "worker", "vm", "machine"].any? { |keyword| card[:name].downcase.include? keyword}
        end

        # predict suitable tag based on card's detailedDescription
        # [koko] : don't use this for now. will lead to misslead data !!!
        # unless card[:detailedDescription].nil?
        #   suitable_tags << "x8KkCFwrAW5jqc7Gx" if card[:detailedDescription].downcase.include? "setup"
        #   suitable_tags << "Y4Gg9AkZKYJAFspTg" if card[:detailedDescription].downcase.include? "access"
        #   suitable_tags << "Hfi25ss7PqBKvHYkQ" << "x8KkCFwrAW5jqc7Gx" if card[:detailedDescription].downcase.include? "vpn"
        #   suitable_tags << "gL2zE25boAyq6moCk" << "x8KkCFwrAW5jqc7Gx" if card[:detailedDescription].downcase.include? "ssh"
        #   suitable_tags << "ioyeWTeuj93m3otbj" << "x8KkCFwrAW5jqc7Gx" if ["box", "ec2", "provision", "worker", "vm", "machine"].any? { |keyword| card[:detailedDescription].downcase.include? keyword}
        # end

        if suitable_tags.length > 0
          puts "#{counter} - name : #{card[:name]}, tags : #{card[:tags]}"
          # remove duplicate
          # puts suitable_tags.uniq

          focused_tags.each do |focused_tag|
            if card[:tags].include? focused_tag
              puts "----- #{translate_focused_tag(focused_tag)} sudah ada!"
            else
              puts "#{translate_focused_tag(focused_tag)} akan ditambahkan ......."
            end
          end
          puts "\n\n"
          
          counter+=1
        end

        suitable_tags = []
      end
    end
  end

end
