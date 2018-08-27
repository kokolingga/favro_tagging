#!/usr/bin/env ruby
require 'optparse'
require 'open3'
require 'json'
require_relative('class/widget')
# require_relative('class/tag')
require_relative('class/card')

# good example
# https://www.thoughtco.com/optionparser-parsing-command-line-options-2907753

# This hash will hold all of the options
# parsed from the command-line by OptionParser.
options = {}

optparse = OptionParser.new do|opts|
  # Set a banner, displayed at the top of the help screen.
  opts.banner = "Usage: favro_tagging_automation.rb [options]"

  # Define the options, and what they do

  # organizationId
  options[:organization_id] = nil
  opts.on( '-o', '--organization_id ORGANIZATION_ID', 'Your Organization ID' ) do |organization_id|
    options[:organization_id] = organization_id
  end

  # widgetCommonId
  options[:widget_id] = nil
  opts.on( '-w', '--widget_id WIDGET_ID', 'Your Widget ID' ) do |widget_id|
    options[:widget_id] = widget_id
  end

  # username
  options[:username] = nil
  opts.on( '-u', '--username USERNAME', 'Your favro e-mail login' ) do |username|
    options[:username] = username
  end

  # token
  options[:token] = nil
  opts.on( '-t', '--token TOKEN', 'Your favro token' ) do |token|
    options[:token] = token
  end

  # This displays the help screen,
  # all programs are assumed to have this option.
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

optparse.parse!


so_cards = Card.new(options)
so_cards.tag_checking_and_applying
puts "okay"
