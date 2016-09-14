# audio-conversion
Proof of concept for audio conversion decisions.  Takes in a WAV file and 
converts it to FLAC and 256KAAC.  Then takes those and converts them each to 64K
MP3 and 48K HE-AAC.

## usage
Install ffmpeg with the additional libfdk-aac encoder:

`brew install ffmpeg --with-fdk-aac `

Install required gems:

`bundle install`

To run all of the conversion options:

`ruby convert.rb --file PATH_TO_FILE`

To convert into a specific format:

`ruby convert.rb --file PATH_TO_FILE --out [flac, aac, he-aac, mp3]`
