#!/local/bin/perl

%dictionary = (
	'a', 0,
	'b', 1,
	'c', 2,
	'd', 3,
	'e', 4,
        'f', 5,
	'g', 6,
	'h', 7,
	'i', 8,
	'j', 9,
	'k', 10,
	'l', 11,
	'm', 12,
	'n', 13,
	'o', 14,
	'p', 15,
	'q', 16,
	'r', 17,
	's', 18,
	't', 19,
	'u', 20,
        'v', 21,
	'w', 22,
	'x', 23,
	'y', 24,
	'z', 25,
	' ', 26
);
	
# smoothing factor
$delta = 0.0001;

# get the number of command line arguments
$argc = @ARGV;
if($argc != 2){
  print "Usage: uni-gram-score uni-gram-model file-path\n";
  exit(0);
}

# Read in the input path
$input_model  = @ARGV[0];
# Read in the output path
$file_path = @ARGV[1];	

# prepare the tri_gram matrix
$alphabet_size = 28;
for($i=0; $i<$alphabet_size; $i++){
  $uni_gram[$i] = 0;
}

$alphabet_size = 28;
for($i=0; $i<$alphabet_size; $i++){
      $dist[$i] = 0;
      $count_gram[$i] = 0;
}

# Read in the tri-gram model
open(inFile, "$input_model") || die("Cannot open the data file $input_model");
@raw_data=<inFile>;
close(inFile);

for($i=0; $i<=$#raw_data; $i++){
  chomp(@raw_data[$i]);
  $string_data = @raw_data[$i]; 
  $string_data =~ s/^\s+//;
  @next_line = split(/\s+/, $string_data);
  $l = @next_line[0];
  $value = @next_line[1];
  $uni_gram[$l] = $value;  
}

  # Read in the tri-gram model
  open(inFile, "$file_path") || die("Cannot open the data file $file_path");
  @raw_data=<inFile>;
  close(inFile);
  
  chomp(@raw_data);
  $string_data = join(" ", @raw_data);
  $string_data =~ tr/A-Z/a-z/;
  @char_set = split(//, $string_data);

$size = $#char_set;

for($i=0; $i<$size; $i++){
  $char = @char_set[$i];
  $idx = get_index(@char_set[$i]);   
  ++$count_gram[$idx];
}
  
$norm=0;
# compute and smooth the tri-gram model
for($i=0; $i<$alphabet_size; $i++){
  $dist[$i] = $count_gram[$i] + ($delta * $alphabet_size);
  $norm +=  $dist[$i];
}
  
for($i=0; $i<$alphabet_size; $i++){
  $dist[$i] /=  $norm;
}

$score = 0;
for($i=0; $i<$alphabet_size; $i++){
  $score += $dist[$i] * log($dist[$i]/$uni_gram[$i]);
} 

print $score, "\n";
exit($score);

sub get_index{
  my $char = $_[0];
  if($char !~ /[a-z]/ && $char !~ /[ ]\s*/){
    return $alphabet_size-1;
  }
  else{
    return $dictionary{$char};
  }  
}
