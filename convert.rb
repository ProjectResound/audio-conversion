require 'rubygems'
require 'optparse'
require 'streamio-ffmpeg'

options = {}
EXTS = %w[flac aac mp3 128k-mp3 he-aac]

OptionParser.new do |opts|
  opts.banner = "Usage: convert.rb [options]"

  opts.on("--file FILENAME", "path to source file") do |f|
    options[:file] = f
  end

  opts.on("--out EXT", EXTS) do |o|
    options[:output] = o
  end
end.parse!

def convert(file:, basename:, og_extension:, output:)
  case output
    when 'flac'
      encoding_options = {
          audio_codec: 'flac'
      }
      output_file = "output/#{basename}#{og_extension}.flac"
    when 'he-aac'
      encoding_options = {
          audio_codec: 'libfdk_aac',
          audio_bitrate: '48'
      }
      output_file = "output/#{basename}#{og_extension}.he-aac.m4a"
    when 'aac'
      encoding_options = {
          audio_codec: 'libfdk_aac',
          audio_bitrate: '256'
      }
      output_file = "output/#{basename}#{og_extension}.m4a"
    when 'mp3'
      encoding_options = {
          audio_codec: 'libmp3lame',
          audio_bitrate: '64'
      }
      output_file = "output/#{basename}#{og_extension}.64k.mp3"
    when '128k-mp3'
      encoding_options = {
          audio_codec: 'libmp3lame',
          audio_bitrate: '128'
      }
      output_file = "output/#{basename}#{og_extension}.128k.mp3"

  end

  start = Time.now
  transcoded_file = file.transcode(output_file, encoding_options)
  finish = Time.now

  puts "Original size: #{(file.size/1048576.0).round}MB"
  puts "Transcoded size: #{(transcoded_file.size/1048576.0).round}MB"
  puts "Transcoded: #{(transcoded_file.audio_stream)}"
  puts "Took: #{(finish - start).round(2)}s"
  puts "===================================================================\n\n\n"
end

if options[:file]
  unless Dir.exist?('output')
    Dir.mkdir('output')
  end

  file = FFMPEG::Movie.new(options[:file])
  basename = File.basename(options[:file], '.*')
  extname = File.extname(options[:file])

  if options[:output]
    convert(
      file: file,
      basename: basename,
      output: options[:output],
      og_extension: extname
    )
  else
  #   Run all the conversions!
    # wav => flac
    convert(
      file: file,
      basename: basename,
      output: 'flac',
      og_extension: extname
    )
    # wav => aac
    convert(
        file: file,
        basename: basename,
        output: 'aac',
        og_extension: extname
    )
    # flac => mp3
    convert(
        file: FFMPEG::Movie.new("output/#{basename}.wav.flac"),
        basename: basename,
        output: 'mp3',
        og_extension: '.flac'
    )
    # flac => 128k-mp3
    convert(
        file: FFMPEG::Movie.new("output/#{basename}.wav.flac"),
        basename: basename,
        output: '128k-mp3',
        og_extension: '.flac'
    )
    # flac => he-aac
    convert(
        file: FFMPEG::Movie.new("output/#{basename}.wav.flac"),
        basename: basename,
        output: 'he-aac',
        og_extension: '.flac'
    )
    # aac => mp3
    convert(
        file: FFMPEG::Movie.new("output/#{basename}.wav.m4a"),
        basename: basename,
        output: 'mp3',
        og_extension: '.aac'
    )
    # aac => 128k-mp3
    convert(
        file: FFMPEG::Movie.new("output/#{basename}.wav.m4a"),
        basename: basename,
        output: '128k-mp3',
        og_extension: '.aac'
    )
    # aac => he-aac
    convert(
        file: FFMPEG::Movie.new("output/#{basename}.wav.m4a"),
        basename: basename,
        output: 'he-aac',
        og_extension: '.aac'
    )
  end

end
