module Attic
  class Agit
    def initialize
      staged
      modified
      deleted
      untracked
    end

    def staged
      return %x[git diff --name-only --cached].split("\n")
    end

    def modified
      modified = %x[git diff --name-status].split("\n")
      real_modified = []
      modified.each { |file| real_modified << file.split("\t")[1] if file[0] == "M" }
      return real_modified
    end

    def deleted
      return %x[git ls-files -d].split("\n")
    end

    def untracked
      return %x[git ls-files --other --exclude-standard].split("\n")
    end

    def all
      file_array = [0]
      self.staged.each { |a| file_array << a }
      self.modified.each { |a| file_array << a }
      self.deleted.each { |a| file_array << a }
      self.untracked.each { |a| file_array << a }
      return file_array
    end
  end
end

module Attic
  class Text
    def self.colorize(text, color_code)
      "\e[#{color_code}m#{text}\e[0m"
    end
    def self.red(text); colorize(text, 31); end
    def self.green(text); colorize(text, 32); end
  end
end

module Attic
  class Commands
    def self.initialize
      @file_obj = Attic::Agit.new
      case ARGV[0]
      when "status"
	      status
      else
        set_args
        other
      end
    end

    def self.row(obj, name)
      if obj.count > 0
        obj.each do |o|
          puts "#       "+Attic::Text.red('('+@count.to_s+') - '+name+' : '+o.to_s)
          @count += 1
        end
      end
    end

    def self.status
      puts %x[git status | head -1]
      @count = 1
      if @file_obj.staged.count > 0
        puts "# Changes to be commited:"
        puts "#   (use \"git reset HEAD <file>...\" to unstage)\n#\n"
        @file_obj.staged.each do |s|
          tag = %x[git status | grep #{s} | head -n 1 | cut -f 2].gsub("\n", "")
          if tag[0] == "m"
            puts "#       "+Attic::Text.green('('+@count.to_s+') - '+tag)
          elsif tag[0] == 'd'
            puts "#       "+Attic::Text.red('('+@count.to_s+') - '+tag)
          else
            puts "#       (#{@count}) - #{tag}"
          end
          @count += 1
        end
        puts "#\n"
      end

      if @file_obj.modified.count > 0 || @file_obj.deleted.count > 0
        puts "# Changesp not staged for commited:"
        puts "#   (use \"git add/rm <file>...\" to update what will be committed)"
        puts "#   (use \"git checkout -- <file>...\" to discard changes in working directory)\n#\n"
      end

      row(@file_obj.modified, "modified")
      row(@file_obj.deleted, "deleleted")

      if @file_obj.untracked.count > 0
        puts "#\n# Untracked files:"
        puts "#   (use \"git add <file>...\" to include in what will be committed)\n#\n"
        @file_obj.untracked.each do |u|
          puts "#       (#{@count}) - #{u}"
          @count += 1
        end
      end
    end
    def self.set_args
      @arg_list = []
      ARGV.each do |a|
        if a.to_i != 0
          @arg_list << @file_obj.all[a.to_i]
        else
          @arg_list << a
        end
      end
    end

    def self.other
      if ARGV[0] == "commit" && ARGV[1] == "-m"
        exec 'git commit -m "'+ARGV[2]+'"'
      else
        exec 'git '+@arg_list.to_s.gsub(/[,\]\["]/, "")
      end
    end
  end
end

Attic::Commands.initialize
