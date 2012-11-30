# POD documentation - main docs before the code

=head1 NAME

GenOO::NGS::Experiment - Object describing a Next Generation Sequencing experiment

=head1 SYNOPSIS

    # Object that offers as an information holder for NGS experiments
    # It contains information about the samples used the type of analysis for every sample and several more attributes
    # It primary goal is to be extensible so that it can describe several types of experiments
    
    # To initialize 
    my $experiment = GenOO::NGS::Experiment->new({
        NAME            => undef,
        SPECIES         => undef,
        DESCRIPTION     => undef,
        PARAMS          => undef,
        EXTRA_INFO      => undef,
    });


=head1 DESCRIPTION

    This object is constructed from an xml file which contains information about a NGS experiment.
    It contains accessors for different types of subexperiments within the main project

=head1 EXAMPLES

    # Read experiment info
    my $experiment_obj = GenOO::NGS::Experiment->read_xml("params.xml);
    
    # Get all samples for a particular sub experiment
    

=head1 AUTHOR - Manolis Maragkakis

Email em.maragkakis@gmail.com

=cut

# Let the code begin...

package GenOO::NGS::Experiment;
use strict;
use XML::Simple;

use base qw( GenOO::_Initializable );

sub _init {
	my ($self,$data) = @_;
	
	$self->read_xml($$data{XML});
	
	return $self;
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_info {
	return $_[0]->{INFO};
}
sub get_name {
	return $_[0]->get_info->{'name'};
}
sub get_path {
	return $_[0]->get_info->{'path'};
}
sub get_species {
	return $_[0]->get_info->{'species'};
}
sub get_species_id {
	return $_[0]->get_info->{'species_id'};
}
sub get_subexperiment_names {
	my ($self) = @_;
	
	if (exists $self->get_info->{'sub_experiment'}) {
		return keys %{$self->get_info->{'sub_experiment'}};
	}
	else {
		return ();
	}
}
sub get_subexperiment {
	my ($self,$name) = @_;
	
	if (exists $self->get_info->{'sub_experiment'}->{$name}) {
		return $self->get_info->{'sub_experiment'}->{$name};
	}
	else {
		return {};
	}
}
sub get_sample_names_for_subexperiment {
	my ($self,$name) = @_;
	
	if (exists $self->get_info->{'sub_experiment'}->{$name}->{'sample'}) {
		return keys %{$self->get_info->{'sub_experiment'}->{$name}->{'sample'}};
	}
	else {
		return ();
	}
}
sub get_samples_for_subexperiment {
	my ($self,$name,$sample_names_ref) = @_;
	
	#if specific names have been asked
	if ((defined $sample_names_ref) and (@$sample_names_ref > 0)) {
		my @outsamples;
		foreach my $sample_name (@$sample_names_ref) {
			if (exists $self->get_info->{'sub_experiment'}->{$name}->{'sample'}->{$sample_name}) {
				push @outsamples, $self->get_info->{'sub_experiment'}->{$name}->{'sample'}->{$sample_name};
			}
		}
		return @outsamples;
	}
	else {
		if (exists $self->get_info->{'sub_experiment'}->{$name}->{'sample'}) {
			my @outsamples = sort {$a->{'name'} cmp $b->{'name'}} values %{$self->get_info->{'sub_experiment'}->{$name}->{'sample'}};
			return @outsamples;
		}
		else {
			return ();
		}
	}
}
sub get_sample {
	my ($self,$name,$sample_name) = @_;
	
	if (exists $self->get_info->{'sub_experiment'}->{$name}->{'sample'}->{$sample_name}) {
		return $self->get_info->{'sub_experiment'}->{$name}->{'sample'}->{$sample_name};
	}
	else {
		return {};
	}
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_name {
	$_[0]->{NAME} = $_[1] if defined $_[1];
}
sub set_path {
	$_[0]->{PATH} = $_[1] if defined $_[1];
}
sub set_species {
	$_[0]->{SPECIES} = $_[1] if defined $_[1];
}
sub set_species_id {
	$_[0]->{SPECIES_ID} = $_[1] if defined $_[1];
}
sub set_info {
	$_[0]->{INFO} = defined $_[1] ? $_[1] : {};
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub read_xml {
	my ($self,$filename) = @_;
	
	$self->set_info(XMLin($filename));
	$self->_process_info();
	# print Dumper($self->get_info);
}
sub write_xml {
	my ($self,$filename) = @_;
	
	open(my $OUT,">",$filename) or die "Cannot write to file $filename $!";
	print $OUT XMLout($self->get_info);
	close $OUT;
}
sub _process_info {
	my ($self,$filename) = @_;
	
	my $info = $self->get_info();
	
	foreach my $subexp_type (keys %{$info->{'sub_experiment'}}) {
		if ($subexp_type eq "") {
			delete $info->{'sub_experiment'}->{$subexp_type};
			next;
		}
		$info->{'sub_experiment'}->{$subexp_type}->{'name'} = $subexp_type;
		foreach my $sample_name (keys %{$info->{'sub_experiment'}->{$subexp_type}->{'sample'}}) {
			if ($sample_name eq "") {
				delete $info->{'sub_experiment'}->{$subexp_type}->{'sample'}->{$sample_name};
				next;
			}
			$info->{'sub_experiment'}->{$subexp_type}->{'sample'}->{$sample_name}->{'name'} = $sample_name;
			$info->{'sub_experiment'}->{$subexp_type}->{'sample'}->{$sample_name}->{'type'} = $subexp_type;
		}

	}
}

1;
