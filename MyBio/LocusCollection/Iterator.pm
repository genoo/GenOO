# POD documentation - main docs before the code

=head1 NAME

MyBio::LocusCollection::Iterator - Iterator object for the MyBio::LocusCollection data structure

=head1 SYNOPSIS

    # Offers iterator methods like "next" for a MyBio::LocusCollection. 

    # To initialize 
    my $locus_collection_iter = MyBio::LocusCollection::Iterator->new({
        DATA_STRUCTURE        => undef,
    });


=head1 DESCRIPTION

    The primary data structure supported by this object is a 2D hash whose primary key is the strand 
    and its secondary key is the chromosome name. Each such pair of keys correspond to an
    array reference which stores generic objects.

=head1 EXAMPLES

    # Get next entry
    my $next_entry = $locus_collection_iter->next();

=cut

# Let the code begin...

package MyBio::LocusCollection::Iterator;
use strict;

use base qw(MyBio::_Initializable);

sub _init {
	my ($self,$data) = @_;
	
	$self->set_data_stucture($$data{DATA_STRUCTURE});
	$self->init;
	
	return $self;
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_data_stucture {
	my ($self, $value) = @_;
	
	if (defined $value) {
		$self->{DATA_STRUCTURE} = $value;
	}
}

#######################################################################
########################   Accessor Methods   #########################
#######################################################################
sub data_stucture {
	my ($self) = @_;
	return $self->{DATA_STRUCTURE};
}

sub strand {
	my ($self) = @_;
	return $self->{STRAND};
}

sub chr {
	my ($self) = @_;
	return $self->{CHR};
}

sub strand_idx {
	my ($self) = @_;
	return $self->{STRAND_IDX};
}

sub chr_idx {
	my ($self) = @_;
	return $self->{CHR_IDX};
}

sub array_idx {
	my ($self) = @_;
	return $self->{ARRAY_IDX};
}

sub strands_ref {
	my ($self) = @_;
	return $self->{STRANDS_REF};
}

sub chrs_ref {
	my ($self) = @_;
	return $self->{CHRS_REF};
}

sub array_ref {
	my ($self) = @_;
	return $self->{ARRAY_REF};
}

#######################################################################
###########################   Init Methods   ##########################
#######################################################################
sub init {
	my ($self) = @_;
	
	$self->init_strand_idx;
	$self->init_chr_idx;
	$self->init_array_idx;
	$self->init_strands_ref;
	$self->update;
}

sub init_strand_idx {
	my ($self) = @_;
	$self->{STRAND_IDX} = 0;
}

sub init_chr_idx {
	my ($self) = @_;
	$self->{CHR_IDX} = 0;
}

sub init_array_idx {
	my ($self) = @_;
	$self->{ARRAY_IDX} = -1;
}

sub init_strands_ref {
	my ($self) = @_;
	$self->{STRANDS_REF} = [keys %{$self->data_stucture}];
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub update {
	my ($self) = @_;
	
	$self->update_strand;
	$self->update_chrs_ref;
	$self->update_chr; # remember to update chrs_ref first (above)
	$self->update_array_ref;
}

sub update_strand {
	my ($self) = @_;
	$self->{STRAND} = $self->strands_ref->[$self->strand_idx];
}

sub update_chr {
	my ($self) = @_;
	$self->{CHR} = $self->chrs_ref->[$self->chr_idx];
}

sub update_chrs_ref {
	my ($self) = @_;
	$self->{CHRS_REF} = [keys %{$self->data_stucture->{$self->strand}}]
}

sub update_array_ref {
	my ($self) = @_;
	$self->{ARRAY_REF} = $self->data_stucture->{$self->strand}->{$self->chr};
}

sub next {
	my ($self) = @_;
	return $self->iterator_closure->();
}

sub iterator_closure {
	my ($self) = @_;
	
	return sub {
		if ($self->next_idx_set) {
			return $self->array_ref->[$self->array_idx];
		}
		else {
			return undef;
		}
	};
}

sub next_idx_set {
	my ($self) = @_;
	
	if ($self->array_idx < $#{$self->array_ref}) {
		$self->increment_array_idx;
	}
	else {
		$self->reset_array_idx;
		if ($self->chr_idx < $#{$self->chrs_ref}) {
			$self->increment_chr_idx;
		}
		else {
			$self->reset_chr_idx;
			if ($self->strand_idx < $#{$self->strands_ref}) {
				$self->increment_strand_idx;
			}
			else {
				$self->init;
				return 0;
			}
		}
	}
	$self->update;
	return 1;
}

sub reset_strand_idx {
	my ($self) = @_;
	$self->{STRAND_IDX} = 0;
}

sub reset_chr_idx {
	my ($self) = @_;
	$self->{CHR_IDX} = 0;
}

sub reset_array_idx {
	my ($self) = @_;
	$self->{ARRAY_IDX} = 0;
}

sub increment_strand_idx {
	my ($self) = @_;
	$self->{STRAND_IDX}++;
}

sub increment_chr_idx {
	my ($self) = @_;
	$self->{CHR_IDX}++;
}

sub increment_array_idx {
	my ($self) = @_;
	$self->{ARRAY_IDX}++;
}

1;
