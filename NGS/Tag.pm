package NGS::Tag;

use warnings;
use strict;

use Locus;
use Clone;

our @ISA = qw( Locus Clone );

# HOW TO INITIALIZE THIS OBJECT
# my $Locus = Tag->new({
# 		     SPECIES      => undef,
# 		     STRAND       => undef,
# 		     CHR          => undef,
# 		     START        => undef,
# 		     STOP         => undef,
# 		     SEQUENCE     => undef,
# 		     NAME         => undef,
# 		     SCORE        => undef,
# 		     THICK_START  => undef,
# 		     THICK_STOP   => undef,
# 		     RGB          => undef,
# 		     BLOCK_COUNT  => undef,
# 		     BLOCK_SIZES  => undef,
# 		     BLOCK_STARTS => undef,
# 		     EXTRA_INFO   => undef,

# 		     });

sub _init {
	
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);
	
	$self->set_name($$data{NAME});
	$self->set_score($$data{SCORE});
	$self->set_thick_start($$data{THICK_START});
	$self->set_thick_stop($$data{THICK_STOP});
	$self->set_rgb($$data{RGB});
	$self->set_block_count($$data{BLOCK_COUNT});
	$self->set_block_sizes($$data{BLOCK_SIZES});
	$self->set_block_starts($$data{BLOCK_STARTS});
	$self->set_extra($$data{EXTRA_INFO});
	$self->set_overlap($$data{OVERLAP});
	
	return $self;
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_name {
	return $_[0]->{NAME};
}
sub get_score {
	return $_[0]->{SCORE};
}
sub get_thick_start {
	return $_[0]->{THICK_START};
}
sub get_thick_stop {
	return $_[0]->{THICK_STOP};
}
sub get_rgb {
	return $_[0]->{RGB};
}
sub get_block_count {
	return $_[0]->{BLOCK_COUNT};
}
sub get_block_sizes {
	return $_[0]->{BLOCK_SIZES};
}
sub get_block_starts {
	return $_[0]->{BLOCK_STARTS};
}
sub get_extra {
	return $_[0]->{EXTRA_INFO} ;
}
sub get_overlap {
	return $_[0]->{OVERLAP} ;
}
#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_name {
	$_[0]->{NAME}=$_[1] if defined $_[1];
}
sub set_score {
	$_[0]->{SCORE}=$_[1] if defined $_[1];
}
sub set_thick_start {
	$_[0]->{THICK_START}=$_[1] if defined $_[1];
}
sub set_thick_stop {
	$_[0]->{THICK_STOP}=$_[1] if defined $_[1];
}
sub set_rgb {
	if (defined $_[1]){
		my $color = $_[1];
		if (lc($color) eq "red"){$color = "205,0,0";}
		elsif (lc($color) eq "black"){$color = "0,0,0";}
		elsif (lc($color) eq "blue"){$color = "0,0,128";}
		elsif (lc($color) eq "green"){$color = "0,100,0";}
		elsif (lc($color) eq "orange"){$color = "255,140,0";}
		elsif (lc($color) eq "magenta"){$color = "205;0;205";}
		$_[0]->{RGB}=$color;
	}
}
sub set_block_count {
	$_[0]->{BLOCK_COUNT}=$_[1] if defined $_[1];
}
sub set_block_sizes {
	$_[0]->{BLOCK_SIZES}=$_[1] if defined $_[1];
}
sub set_block_starts {
	$_[0]->{BLOCK_STARTS}=$_[1] if defined $_[1];
}
sub set_extra {
	$_[0]->{EXTRA_INFO} = $_[1] if defined $_[1];
}
sub set_overlap {
	my ($self, $key, $value) = @_;
	if ((defined $key) and (defined $value)){$self->{OVERLAP}->{$key} = $value;}
	else {$self->{OVERLAP} = {};}
}

#######################################################################
##########################   Class Methods   ##########################
#######################################################################
sub output_tag {
	my ($class,$method,@attributes) = @_;
		
	my $print_tag;
	if ($method eq "BED") {
		my $strand;
		if ($class->get_strand == 1){$strand = "+";}
		elsif ($class->get_strand == -1){$strand = "-";}
		else {$strand = ".";}
		
		my $name = defined $class->get_name ? $class->get_name : ".";
		my $score = defined $class->get_score ? $class->get_score : 0;
		
		$print_tag = "chr".$class->get_chr."\t".$class->get_start."\t".($class->get_stop+1)."\t".$name."\t".$class->get_score."\t".$strand;
		
		$print_tag .= defined $class->get_thick_start ? "\t".$class->get_thick_start : "\t";
		$print_tag .= defined $class->get_thick_stop ? "\t".$class->get_thick_stop : "\t";
		$print_tag .= defined $class->get_rgb ? "\t".$class->get_rgb : "\t";
		$print_tag .= defined $class->get_block_count ? "\t".$class->get_block_count : "\t";
		$print_tag .= defined $class->get_block_sizes ? "\t".$class->get_block_sizes : "\t";
		$print_tag .= defined $class->get_block_starts ? "\t".$class->get_block_starts : "\t";
	}
	$print_tag =~ s/\t+$//g;
	return $print_tag;
}

1;