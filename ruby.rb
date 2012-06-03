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

    def array
      file_array = []
      file_array << self.staged
      file_array << self.modified
      file_array << self.deleted
      file_array << self.untracked
    end
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
      end
    end

    def self.status
      puts @file_obj.array
    end
  end
end

Attic::Commands.initialize
