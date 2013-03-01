require 'git'
require 'time'
require 'date'

$letters = {
  " " => %w(
0 0 0 0 0
0 0 0 0 0
0 0 0 0 0
0 0 0 0 0
0 0 0 0 0
0 0 0 0 0
0 0 0 0 0
),
  "A" => %w(
0 0 1 0 0
0 1 0 1 0
1 0 0 0 1
1 1 1 1 1
1 0 0 0 1
1 0 0 0 1
1 0 0 0 1
),
}

class Forger
  @@WIDTH=50
  @@HEIGHT=7
  @@COMMITS_PER_DAY=5
  @@OFFSET_INTO_DAY=3600 # seconds

  def initialize folder=nil
    @g = if folder.nil?
      Git.init
    else
      Git.init folder
    end
    start = Date.today - 365 + 7
    @origin = start - start.wday
  end

  def commit_at time, message='derp'
    ENV['GIT_COMMITTER_DATE'] = ENV['GIT_AUTHOR_DATE'] = time.iso8601
    File.open('herp', 'w') { |file| file.write time.iso8601 }
    @g.add '.'
    @g.commit_all message, :allow_empty => true
    puts "Committing at #{ENV['GIT_COMMITTER_DATE']}"
  end

  def time_for_coords x, y
    Time.parse((@origin + (7 * x) + y).to_s) + @@OFFSET_INTO_DAY
  end

  def write message
    @i = 0
    message.each_char do |c|
      break if @i >= @@WIDTH
      bitmap = $letters[c]
      height = 7
      width = bitmap.length / height
      (0...width).each do |x|
        return if @i + x > width
        (0...height).each do |y|
          if bitmap[(width * y) + x] == "1"
            puts "#{x}, #{y}, bitmap[#{(width * y) + x}] == #{bitmap[(width * y) + x]}"
            (0..@@COMMITS_PER_DAY).each do |z|
              commit_at time_for_coords(@i + x, y)
            end
          end
        end
      end
      @i += width
    end
  end
end

Forger.new.write "A"
