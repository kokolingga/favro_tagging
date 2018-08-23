class Tag
  attr_accessor :array_of_raw_tags, :clean_tags

  def initialize(array_of_raw_tags)
    @array_of_raw_tags = array_of_raw_tags
    @clean_tags = set_clean_tags()
  end

  def set_clean_tags
    clean_tags_arr = Array.new()

    @array_of_raw_tags.each do |raw_tag|
      raw_tag["entities"].each do |tag|
        clean_tags_arr << {tagId: tag["tagId"], name: tag["name"], color: tag["color"]}
      end
    end

    return clean_tags_arr
  end

  def show_clean_tags
    counter=1
    @clean_tags.each do |tag|
      puts "#{counter} - tagId : #{tag[:tagId]}, name : #{tag[:name]}, color : #{tag[:color]}"
      counter+=1
    end
  end
end
