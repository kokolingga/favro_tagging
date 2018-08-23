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
        clean_cards_arr << {cardId: card["cardId"], name: card["name"], archived: card["archived"], tags: card["tags"]}
      end
    end

    return clean_cards_arr
  end

  def show_clean_cards
    counter=1
    @clean_cards.each do |card|
      puts "#{counter} - cardId : #{card[:cardId]}, name : #{card[:name]}, archived : #{card[:archived]}, tags : #{card[:tags]}"
      counter+=1
    end
  end
end
