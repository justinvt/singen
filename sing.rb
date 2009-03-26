#!/usr/bin/ruby

ROOT = IO.popen("echo $PWD").read.strip
@directory   = ARGV[0]
@project_dir = File.join(ROOT, @directory.to_s)
@app_filename = "app.rb"

gems = [:rubygems, :sinatra, :data_mapper]
default_methods = [:boot]

directories   =  { @directory => [:views, :models, :lib, {:public =>[:javascripts, :css, {:images=>[:icons]} ] } ] }

def make_dir(path)
  path = path.to_s
  File.exists?(path.to_s) ? puts("#{File.expand_path path} already exists") : (d = Dir.mkdir(path.to_s); puts "#{File.expand_path path} created" unless d.nil? )
  path
end

def make_dirs(array)
  array = array.map(&:to_s)
  made = []
  while !array.empty?
    made << array.shift
    make_dir File.join(made)
  end
  made
end

def dirs(dirs, inside=nil)
  a = dirs
  if a.is_a? Hash
    a.each_pair do |k,v|
      make_dir(k)
      Dir.chdir(k.to_s)
      v.each do |i|
        if [Symbol, String].include? i.class
          make_dir(i)
        elsif i.class.name.match /Hash/
          dirs(i)
        end
      end
    end
  elsif a.is_a? Array
    make_dirs a
  end
end

puts "\nCreating project \"#{@directory}\""

dirs(directories)

Dir.chdir(@project_dir)

unless File.exists?(@app_filename)
  f = File.open(@app_filename, "a")
  gems.each{|g| f.puts "require \"#{g}\""}
  f.puts "\n"
  default_methods.each{|m| f.puts "#TODO -  #{m}"}
  f.close
else
  puts "#{@app_filename} already exists"
end

if File.exists?("/Applications/TextMate.app")
  system "mate #{@project_dir}"
end
