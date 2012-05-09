# POD documentation - main docs before the code

=head1 NAME

MyBio::Data::File::SAM::Record - Object representing a record of a sam file

=head1 SYNOPSIS

    # Object representing a record of a sam file 

    # To initialize 
    my $sam_record = MyBio::Data::File::SAM::Record->new({
        QNAME      => undef,
        FLAG       => undef,
        RNAME      => undef,
        POS        => undef,
        MAPQ       => undef,
        CIGAR      => undef,
        RNEXT      => undef,
        PNEXT      => undef,
        TLEN       => undef,
        SEQ        => undef,
        QUAL       => undef,
        EXTRA_INFO => undef,
    });


=head1 DESCRIPTION

    This object represents a record of a sam file and offers methods for accessing the different attributes.
    It implements several additional methods that transform original attributes in more manageable attributes.
    eg. from the FLAG attribute the actual strand is extracted etc.

=head1 EXAMPLES

    # Check if the record corresponds to a match
    my $mapped = $sam_record->is_mapped();
    
    # Check if the record corresponds to a non match
    my $unmapped = $sam_record->is_unmapped();
    
    # Parse the FLAG attribute and return 1 or -1 for the strand
    my $strand = $sam_record->get_strand();

=head1 AUTHOR - Manolis Maragkakis

Email em.maragkakis@gmail.com

=cut

# Let the code begin...

package MyBio::Data::File::SAM::Record;
use strict;

use base qw( MyBio::_Initializable );

our $VERSION = '1.0';

sub _init {
	my ($self,$data) = @_;
	
	$self->set_qname($$data{QNAME}); # String [!-?A-~]f1,255g Query template NAME
	$self->set_flag($$data{FLAG});   # Int [0,216-1] bitwise FLAG
	$self->set_rname($$data{RNAME}); # String \*|[!-()+-<>-~][!-~]* Reference sequence NAME
	$self->set_pos($$data{POS});     # Int [0,229-1] 1-based leftmost mapping POSition
	$self->set_mapq($$data{MAPQ});   # Int [0,28-1] MAPping Quality
	$self->set_cigar($$data{CIGAR}); # String \*|([0-9]+[MIDNSHPX=])+ CIGAR string
	$self->set_rnext($$data{RNEXT}); # String \*|=|[!-()+-<>-~][!-~]* Ref. name of the mate/next segment
	$self->set_pnext($$data{PNEXT}); # Int [0,229-1] Position of the mate/next segment
	$self->set_tlen($$data{TLEN});   # Int [-229+1,229-1] observed Template LENgth
	$self->set_seq($$data{SEQ});     # String \*|[A-Za-z=.]+ segment SEQuence
	$self->set_qual($$data{QUAL});   # String [!-~]+ ASCII of Phred-scaled base QUALity+33
}

#######################################################################
########################   Attribute Setters   ########################
#######################################################################
sub set_qname {
	my ($self,$value) = @_;
	return $self->{QNAME}=$value if defined $value;
}
sub set_flag {
	my ($self,$value) = @_;
	return $self->{FLAG}=$value if defined $value;
}
sub set_rname {
	my ($self,$value) = @_;
	return $self->{RNAME}=$value if defined $value;
}
sub set_pos {
	my ($self,$value) = @_;
	return $self->{POS}=$value if defined $value;
}
sub set_mapq {
	my ($self,$value) = @_;
	return $self->{MAPQ}=$value if defined $value;
}
sub set_cigar {
	my ($self,$value) = @_;
	return $self->{CIGAR}=$value if defined $value;
}
sub set_rnext {
	my ($self,$value) = @_;
	return $self->{RNEXT}=$value if defined $value;
}
sub set_pnext {
	my ($self,$value) = @_;
	return $self->{PNEXT}=$value if defined $value;
}
sub set_tlen {
	my ($self,$value) = @_;
	return $self->{TLEN}=$value if defined $value;
}
sub set_seq {
	my ($self,$value) = @_;
	return $self->{SEQ}=$value if defined $value;
}
sub set_qual {
	my ($self,$value) = @_;
	return $self->{QUAL}=$value if defined $value;
}

#######################################################################
########################   Attribute Getters   ########################
#######################################################################
sub get_qname {
	my ($self) = @_;
	return $self->{QNAME};
}
sub get_flag {
	my ($self) = @_;
	return $self->{FLAG};
}
sub get_rname {
	my ($self) = @_;
	return $self->{RNAME};
}
sub get_pos {
	my ($self) = @_;
	return $self->{POS};
}
sub get_mapq {
	my ($self) = @_;
	return $self->{MAPQ};
}
sub get_cigar {
	my ($self) = @_;
	return $self->{CIGAR};
}
sub get_rnext {
	my ($self) = @_;
	return $self->{RNEXT};
}
sub get_pnext {
	my ($self) = @_;
	return $self->{PNEXT};
}
sub get_tlen {
	my ($self) = @_;
	return $self->{TLEN};
}
sub get_seq {
	my ($self) = @_;
	return $self->{SEQ};
}
sub get_qual {
	my ($self) = @_;
	return $self->{QUAL};
}

#######################################################################
############################   Accessors   ############################
#######################################################################
sub get_start {
	my ($self) = @_;
	return $self->get_pos - 1;
}
sub get_stop {
	my ($self) = @_;
	return $self->get_start + length($self->get_seq) - 1;
}
sub get_strand {
	my ($self) = @_;
	
	if ($self->get_flag & 16) {
		return -1;
	}
	elsif ($self->is_mapped) {
		return 1;
	}
	else {
		return undef;
	}
}
sub get_strand_symbol {
	my ($self) = @_;
	
	my $strand = $self->get_strand;
	if ($strand == 1) {
		return '+';
	}
	elsif ($strand == -1) {
		return '-';
	}
	else {
		return undef;
	}
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub is_mapped {
	my ($self) = @_;
	
	if ($self->get_flag & 4) {
		return 0;
	}
	else {
		return 1;
	}
}

sub is_unmapped {
	my ($self) = @_;
	
	if ($self->get_flag & 4) {
		return 1;
	}
	else {
		return 0;
	}
}

# TODO 
# sub parse_cigar_and_mdz_tag {
# 	my ($self, $tag, $cigar) = @_
# 	
# # 	CIGAR: 2M1I7M6D26M
# # 	MD:Z:3C3T1^GCTCAG26
# # 	AGTGATGGGA------GGATGTCTCGTCTGTGAGTTACAGCA
# # 	-   -
# # 	AG-GCTGGTAGCTCAGGGATGTCTCGTCTGTGAGTTACAGCA
# # 
# # 	Positive strand match AGTGATGGGAGGATGTCTCGTCTGTGAGTTACAGCA
# # 	Reference genome = AGGCTGGTAGCTCAGGGATGTCTCGTCTGTGAGTTACAGCA
# 	
# 	my $query = $self->get_seq;
# 	my $target = '';
# 	my $pos = 0;
# 	my $deletion_string_flag = 0;
# 	while ($tag ne '') {
# 		if ($tag =~ s/^(\d+)//) {
# 			
# 			$deletion_string_flag = 0;
# 			$target .= substr($query,$pos,$1);
# 			$pos += $1;
# 		}
# 		elsif ($tag =~ s/^(\^)//) {
# 			$deletion_string_flag = 1;
# 		}
# 		elsif ($tag =~ s/^([ATGCN])//) {
# 			if ($deletion_string_flag == 1) {
# 				$target .= $1;
# 				substr($query,$pos,0,"-");
# 				$pos += 1;
# 			}
# 			else {
# 				$target .= lc($1);
# 				my $query_nt = substr($query,$pos,1);
# 				substr($query,$pos,1,lc($query_nt));
# # 				my $old = substr($exploded_alignment,$pos+$insertion_count[$pos],1,"m");
# 				$pos += 1;
# # 				if ($old eq "D"){print "DELETION\n"; $dieflag=1;}
# 				
# 			}
# 		}
# 	}
# 	
# 	$pos= 0;
# 	while ($alignment =~ s/(\d+)([MID])//)
# 	{
# 		my $count = $1;
# 		my $type = $2;
# 		if ($type eq 'I') {
# 			substr($target,$pos,0,"-" x $count);
# 		}
# 		if ($type ne 'D') {
# 			$pos += $count;
# 		}
# 	}
# }







1;
