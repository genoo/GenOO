# POD documentation - main docs before the code

=head1 NAME

MyBio::NGS::Tag - Object that represents an area in the genome

=head1 SYNOPSIS

    # Instantiate 
    my $tag = MyBio::NGS::Tag->new({
        SPECIES      => undef,
        STRAND       => undef,
        CHR          => undef,
        START        => undef,
        STOP         => undef,
        SEQUENCE     => undef,
        NAME         => undef,
        SCORE        => undef,
        EXTRA_INFO   => undef,
    });


=head1 DESCRIPTION

    This class corresponds to an area in the genome together with a score for this area.

=head1 EXAMPLES

    # Get tag start
    $tag->start;
    
    # Get tag score
    $tag->score;

=cut

# Let the code begin...

package MyBio::NGS::Tag;
use strict;

use base qw(MyBio::Locus Clone);

# HOW TO INITIALIZE THIS OBJECT
# my $Locus = MyBio::NGS::Tag->new({
# 	SPECIES      => undef,
# 	STRAND       => undef,
# 	CHR          => undef,
# 	START        => undef,
# 	STOP         => undef,
# 	SEQUENCE     => undef,
# 	NAME         => undef,
# 	SCORE        => undef,
# 	THICK_START  => undef,
# 	THICK_STOP   => undef,
# 	RGB          => undef,
# 	BLOCK_COUNT  => undef,
# 	BLOCK_SIZES  => undef,
# 	BLOCK_STARTS => undef,
# 	EXTRA_INFO   => undef,
# });

sub _init {
	
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);
	$self->set_score($$data{SCORE});
	
	return $self;
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_score {
	my ($self, $value) = @_;
	$self->{SCORE} = $value if defined $value;
}

#######################################################################
############################   Accessors   ############################
#######################################################################
sub score {
	my ($self) = @_;
	return $self->{SCORE};
}


#######################################################################
#########################   General Methods   #########################
#######################################################################
sub to_string {
	my ($self, $params) = @_;
	
	my $method;
	if ($params eq 'BED'){
		warn "Don't panic - Just use hash notation when calling ".(caller(0))[3]." in script $0 - Your output is ok.\n";
		$method = 'BED';
	}
	else {
		$method = exists $params->{'METHOD'} ? $params->{'METHOD'} : undef;
	}
	
	if ($method eq 'BED') {
		return $self->to_string_bed;
	}
	else {
		die "\n\nUnknown or no method provided when calling ".(caller(0))[3]." in script $0\n\n";
	}
}

sub to_string_bed {
	my ($self) = @_;
	
	my $strand = defined $self->strand_symbol ? $self->strand_symbol : ".";
	my $name = defined $self->name ? $self->name : ".";
	return $self->chr."\t".$self->start."\t".($self->stop+1)."\t".$name."\t".$self->score."\t".$strand;
}

#######################################################################
#############################   Deprecated   ##########################
#######################################################################
sub get_score {
	my ($self) = @_;
	warn 'Deprecated method "get_score". Consider using "score" instead';
	return $self->score;
}

sub get_overlap {
	warn 'Deprecated method "get_overlap".';
	return $_[0]->{OVERLAP} ;
}


sub set_overlap {
	my ($self, $key, $value) = @_;
	warn 'Deprecated method "set_overlap".';
	if ((defined $key) and (defined $value)){$self->{OVERLAP}->{$key} = $value;}
	else {$self->{OVERLAP} = {};}
}

1;