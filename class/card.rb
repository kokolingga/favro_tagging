class Card < Widget
  attr_accessor :raw_cards, :clean_cards, :options

  # def initialize(raw_cards)
  def initialize(options)
    super options
    @options = options
    @raw_cards = set_raw_cards()      # test pending
    @clean_cards = set_clean_cards()  # test pending
  end

  def set_raw_cards
    get_array_of_raw_json("https://favro.com/api/v1/cards?widgetCommonId=#{options[:widget_id]}&archived=true", "GET")
  end

  def set_clean_cards
    # puts "set_clean_cards ..."

    clean_cards_arr = Array.new()

    @raw_cards.each do |raw_card|
      raw_card["entities"].each do |card|
        clean_cards_arr << {cardId: card["cardId"], name: card["name"], archived: card["archived"], tags: card["tags"], detailedDescription: card["detailedDescription"]}
      end
    end
    # print " finished."
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

  def translate_tag(tag_id)
    case tag_id
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
    # predict tag from title, check if tag is already exist

    suitable_tags = []

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

        # remove duplicate
        suitable_tags.uniq!

        if suitable_tags.length > 0
          puts "#{counter} - card id : #{card[:cardId]}, name : #{card[:name]}, tags : #{card[:tags]}"

          suitable_tags.each do |suitable_tag|
            if card[:tags].include? suitable_tag
              puts "----- #{translate_tag(suitable_tag)} sudah ada!"
            else
              puts "#{translate_tag(suitable_tag)} akan ditambahkan ......."
            end
          end
          puts "\n\n"

          counter+=1
        end

        suitable_tags = []
      end
    end
  end

  def tag_checking_and_applying
    # predict tag from title, check if tag is already exist
    puts "[start] tag_checking_and_applying ..."

    suitable_tags = []
    applied_suitable_tags = []
    counter=1

    @clean_cards.each do |card|
      if card[:archived] == true
        # predict suitable tag based on card's name
        unless card[:name].nil?
          suitable_tags << "x8KkCFwrAW5jqc7Gx" if card[:name].downcase.include? "setup"
          suitable_tags << "Y4Gg9AkZKYJAFspTg" if card[:name].downcase.include? "access"
          suitable_tags << "Hfi25ss7PqBKvHYkQ" << "x8KkCFwrAW5jqc7Gx" if card[:name].downcase.include? "vpn"
          suitable_tags << "gL2zE25boAyq6moCk" << "x8KkCFwrAW5jqc7Gx" if card[:name].downcase.include? "ssh"
          suitable_tags << "ioyeWTeuj93m3otbj" << "x8KkCFwrAW5jqc7Gx" if ["box", "ec2", "provision", "worker", "vm", "machine"].any? { |keyword| card[:name].downcase.include? keyword}
        end

        suitable_tags.uniq! # remove duplicate

        # re-check suitable tag. we don't need to apply existing suitable tag
        # we will setup applied_suitable_tags
        if suitable_tags.length > 0
          puts "........................................................................................."
          puts "*1) #{counter} - card id : #{card[:cardId]}, name : #{card[:name]}, tags : #{card[:tags]}"
          puts "*2) your suitable tags : #{suitable_tags}"

          suitable_tags.each do |suitable_tag|
            if card[:tags].include? suitable_tag
              puts "----- #{translate_tag(suitable_tag)} sudah ada!"
            else
              puts "#{translate_tag(suitable_tag)} akan ditambahkan ......."
              applied_suitable_tags << suitable_tag
            end
          end

          # applied_suitable_tags is ready to use
          puts "*3) your applied suitable tags : #{applied_suitable_tags}"
          param = "{\"addTagIds\": #{applied_suitable_tags}}"
          execute_api("https://favro.com/api/v1/cards/#{card[:cardId]}", "PUT", param, 0)

          puts "*4) your param : #{param} \n\n"
          applied_suitable_tags = []
          suitable_tags = []
          counter+=1

          # ...
        end

      end
    end

    puts "[end] tag_checking_and_applying ..."
  end



  def update_card_test


    card_id = "d9bd6ae5817bc3e6f8917b65"
    arr_of_tags = ["x8KkCFwrAW5jqc7Gx", "Y4Gg9AkZKYJAFspTg", "Hfi25ss7PqBKvHYkQ", "gL2zE25boAyq6moCk", "ioyeWTeuj93m3otbj"]
    param = "{\"addTagIds\": #{arr_of_tags}}"

    execute_api("https://favro.com/api/v1/cards/#{card_id}", "PUT", param, 0)
  end

  def get_card_by_id(card_id)
    puts "Yo, this is from get_card_by_id"

    card = execute_api("https://favro.com/api/v1/cards/#{card_id}", "GET", "", 0)

    puts "\n-------\n"
    puts card["cardId"]
    puts "\n-------\n"
    puts card["tags"]
  end




end
