require 'git'
require 'time'
require 'date'

class Vandal
  @@WIDTH=50
  @@HEIGHT=7
  @@COMMITS_PER_DAY=50
  @@OFFSET_INTO_DAY=3600 # seconds

  def initialize folder
    @folder = folder
    @g = Git.init @folder
    start = Date.today - 365 + 7
    @origin = start - start.wday
    @letter_cache = {}
  end

  def commit_at time, message='derp'
    ENV['GIT_COMMITTER_DATE'] = ENV['GIT_AUTHOR_DATE'] = time.iso8601
    File.open("#{@folder}/herp", 'w') { |file| file.write time.iso8601 }
    @g.add '.'
    @g.commit_all message, :allow_empty => true
  end

  def time_for_coords x, y
    Time.parse((@origin + (7 * x) + y).to_s) + @@OFFSET_INTO_DAY
  end

  def write message
    @i = 0
    print "Writing message: "
    message.upcase.each_char do |c|
      break if @i >= @@WIDTH
      bitmap, width, height = bitmap_for c
      print c
      (0...width).each do |x|
        break if @i + x > @@WIDTH
        (0...height).each do |y|
          if bitmap[(width * y) + x] != " "
            (0..@@COMMITS_PER_DAY).each do |z|
              commit_at time_for_coords(@i + x, y)
            end
          end
        end
      end
      @i += width
    end
    puts
    puts "Forged #{@g.log(32767).count} commits."
    puts "To push to Github, create the repo and run the following:"
    puts "  cd #{@folder}"
    puts "  git remote add origin git@github.com:YOU/REPO.git"
    puts "  git push -u origin master"
  end

  def bitmap_for char
    if not @letter_cache.include? char
      path = "#{File.dirname(__FILE__)}/letters/%03d" % char.ord
      if File.exists? path
        lines = File.open(path).readlines.collect{ |l| l.gsub! "\n", '' }
        height = 7
        width = lines.collect{ |l| l.length }.max
        data = lines.collect{ |l| l + (" " * (width - l.length))}.join
        @letter_cache[char] = [data, width, height]
      else
        raise "Warning: Missing character bitmap for #{char}. Omitting."
      end
    end
    return @letter_cache[char]
  end
end

raise "Usage: ruby vandal.rb <path_to_git_repo>" if not ARGV[0]
Vandal.new(ARGV[0]).write "HIRE ME"
