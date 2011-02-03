package Locus;

use warnings;
use strict;

use _Initializable;

our $VERSION = '1.0';

our @ISA = qw( _Initializable );

# HOW TO INITIALIZE THIS OBJECT
# my $Locus = Locus->new({
# 		     SPECIES      => undef,
# 		     STRAND       => undef,
# 		     CHR          => undef,
# 		     START        => undef,
# 		     STOP         => undef,
# 		     SEQUENCE     => undef,
# 		     EXTRA_INFO   => undef,
# 		     });

sub _init {
	my ($self,$data) = @_;
	
	$self->set_species($$data{SPECIES});
	$self->set_strand($$data{STRAND});
	$self->set_chr($$data{CHR});
	$self->set_start($$data{START});
	$self->set_stop($$data{STOP});
	$self->set_sequence($$data{SEQUENCE});
	$self->set_extra($$data{EXTRA_INFO});
	
	return $self;
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_species {
	return $_[0]->{SPECIES};
}
sub get_strand {
	return $_[0]->{STRAND};
}
sub get_chr {
	return $_[0]->{CHR};
}
sub get_start {
	return $_[0]->{CHR_START};
}
sub get_stop {
	return $_[0]->{CHR_STOP};
}
sub get_sequence {
	return $_[0]->{SEQUENCE};
}
sub get_extra {
	return $_[0]->{EXTRA_INFO};
}
sub get_length {
	if    (defined $_[0]->{LENGTH})   {
	}
	elsif (defined $_[0]->{SEQUENCE}) {
		$_[0]->{LENGTH} = length($_[0]->get_sequence);
	}
	else {
		$_[0]->{LENGTH} = $_[0]->get_stop - $_[0]->get_start + 1;
	}
	return $_[0]->{LENGTH};
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_species {
	$_[0]->{SPECIES} = uc($_[1]) if defined $_[1];
}
sub set_strand {
	my ($self,$value) = @_;
	if (defined $value) {
		$value =~ s/^\+$/1/;
		$value =~ s/^\-$/-1/;
		$self->{STRAND} = $value;
	}
	else {
		$self->{STRAND} = 0;
	}
}
sub set_chr {
	my ($self,$value) = @_;
	if (defined $value) {
		$value =~ s/>*chr//;
		$self->{CHR} = $value;
	}
}
sub set_start {
	$_[0]->{CHR_START} = $_[1] if defined $_[1];
}
sub set_stop {
	$_[0]->{CHR_STOP} = $_[1] if defined $_[1];
}
sub set_sequence {
	my ($self,$value) = @_;
	if (defined $value) {
		$value =~ /([^ATGCUN])/i;
		warn "\n\nWARNING:\nNucleotide sequence provided contains invalid characters ($1)\n\n";
		$self->{SEQUENCE} = $value;
	}
}
sub set_extra {
	$_[0]->{EXTRA_INFO} = $_[1] if defined $_[1];
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub overlaps {
	my ($self,$loc2,$offset) = @_;
	
	if (!defined $offset) {$offset = 0;}
	if ((($self->get_start()-$offset) <= $loc2->get_stop()) and ($loc2->get_start() <= ($self->get_stop()+$offset))) {
		return 1; #overlap
	}
	return 0; #no overlap
}

sub contains {
	my ($self,$loc2,$percent) = @_;
	
	if (!defined $percent) {$percent = 1;}
	my $overhang = 0;
	my $left_overhang = ($self->get_start - $loc2->get_start);
	my $right_overhang = ($loc2->get_stop - $self->get_stop);
	if ($left_overhang > 0){$overhang += $left_overhang;}
	if ($right_overhang > 0){$overhang += $right_overhang;}
# 	print $self->get_start." - ".$self->get_stop."\t".$loc2->get_start." - ".$loc2->get_stop."\t".($overhang / $loc2->get_length)."\t".$percent."\n";
	if (($overhang / $loc2->get_length) <= (1-$percent)){return 1;}
	return 0;
}

1;