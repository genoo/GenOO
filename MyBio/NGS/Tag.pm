package MyBio::NGS::Tag;

use warnings;
use strict;
use Clone;

use MyBio::Locus;

our @ISA = qw( MyBio::Locus Clone );

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
#########################   General Methods   #########################
#######################################################################
sub output_tag {
	my ($self,$method,@attributes) = @_;
	$self->to_string($method,@attributes);
}
sub to_string {
	my ($self,$method,@attributes) = @_;
		
	my $print_tag;
	if ($method eq "BED") {
		my $strand;
		if    ($self->get_strand == 1){$strand = "+";}
		elsif ($self->get_strand == -1){$strand = "-";}
		else {$strand = ".";}
		
		my $name = defined $self->get_name ? $self->get_name : ".";
		my $score = defined $self->get_score ? $self->get_score : 0;
		
		$print_tag = "chr".$self->get_chr."\t".$self->get_start."\t".($self->get_stop+1)."\t".$name."\t".$self->get_score."\t".$strand;
		
		$print_tag .= defined $self->get_thick_start ? "\t".$self->get_thick_start : "\t";
		$print_tag .= defined $self->get_thick_stop ? "\t".$self->get_thick_stop : "\t";
		$print_tag .= defined $self->get_rgb ? "\t".$self->get_rgb : "\t";
		$print_tag .= defined $self->get_block_count ? "\t".$self->get_block_count : "\t";
		$print_tag .= defined $self->get_block_sizes ? "\t".$self->get_block_sizes : "\t";
		$print_tag .= defined $self->get_block_starts ? "\t".$self->get_block_starts : "\t";
	}
	$print_tag =~ s/\t+$//g;
	return $print_tag;
}

1;