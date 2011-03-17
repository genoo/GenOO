package MyBio::Interaction::MirnaCDS;

# Corresponds to a miRNA binding site on the 5'UTR of a gene transcript.

use warnings;
use strict;

use MyBio::Interaction::MRE;
use MyBio::MyMath;

our @ISA = qw(MyBio::Interaction::MRE);

# HOW TO CREATE THIS OBJECT
# my $utr5Obj = MyBio::Transcript::UTR5->new({
# 		   SPLICE_STARTS  => undef, 
# 		   SPLICE_STOPS   => undef, 
# 		   LENGTH      => undef, 
# 		   SEQUENCE     => undef, 
# 		   ACCESSIBILITY  => undef, 
# 		   CONSERVATION   => undef, 
# 		   EXTRA_INFO    => undef, 
# 		   });

sub _init {
	my ($self, $data) = @_;
	
	$self->{WHERE} = 'CDS';
	$self->SUPER::_init($data);
	
	return $self;
}

#######################################################################
#############################  Getters  #############################
#######################################################################

sub get_binding_weight {
	my ($self) = @_;
	unless (defined $self->{BINDING_WEIGHT}) {
		$self->{BINDING_WEIGHT} = $self->_return_binding_category_weight();
	}
	return $self->{BINDING_WEIGHT};
}
sub get_distance_from_previously_allowed {
	my ($self) = @_;
	unless (defined $self->{DISTANCE_FROM_PREVIOUS_ALLOWED}) {
		$self->{DISTANCE_FROM_PREVIOUS_ALLOWED} = $self->_find_distance_from_previously_allowed_MRE();
	}
	return $self->{DISTANCE_FROM_PREVIOUS_ALLOWED};
}
sub get_bpos0_with_bpos10 {
	my ($self) = @_;
	unless (defined $self->{BPOS_FEATURE}) {
		$self->{BPOS_FEATURE} = $self->_calculate_bpos0_with_bpos10_feature();
	}
	return $self->{BPOS_FEATURE};
}
sub get_mre_score {
	my ($self, $version) = @_;
	
	unless (defined $self->{MRE_SCORE}) {
		if ($version eq '5.0') {
			$self->{MRE_SCORE} = $self->_calculate_mre_score_for_version_5_0();
		}
	}
	return $self->{MRE_SCORE};
}

#######################################################################
#############################  Setters  #############################
#######################################################################


#######################################################################
##########################  Class Methods  ##########################
#######################################################################


#######################################################################
#########################  General Methods  #########################
#######################################################################

sub is_allowed {
	my ($self) = @_;
	
	# This array contains 1 for the allowed new categories and 0 for the non allowed. Note that $allowed[0] corresponds to the intercept and therefore is never read. 
	my @allowed = (1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	return $allowed[$self->get_new_category()];
}

sub _return_binding_category_weight {
	my ($self) = @_;
	
	# note that there are 64 binding categories but the @weights array contains 65 elements (the first element of the array is the intercept - never used)
	my @weights = (-4.90, -9.65, 1.08, -9.70, 0.99, -9.67, 0.10, -0.18, -0.59, -0.48, -1.13, 0.10, -9.67, -9.66, 0.03, 0.00, 0.00, 0.00, 0.00, -9.66, 0.70, 0.00, 0.69, 0.00, -0.64, 0.00, 0.00, 0.00, -9.67, -9.69, -0.10, 0.00, 0.00, 2.33, 1.47, -9.69, 1.26, -9.67, 0.76, 0.73, 0.72, 0.33, 0.09, 0.57, 1.81, -9.67, 0.02, 0.00, 0.00, 0.00, 0.00, 2.12, 1.09, -9.67, 0.39, 0.00, -0.15, 0.00, 0.00, 0.00, 0.21, -9.67, 0.00, 0.00, 0.00);
	
	return $weights[$self->get_new_category()];
}

sub _find_distance_from_previously_allowed_MRE {
	my ($self) = @_;
	
	my $distance_from_previously_allowed_MRE = $self->get_position(); #initialize to distance from start
	my @all_MREs = @{$self->get_mirnaTranscriptInteraction->get_mres()};
	
	for (my $i=0;$i<@all_MREs;$i++) {
		my $mre = $all_MREs[$i];
		if (($mre->get_where eq 'CDS') && ($mre->is_allowed) && ($mre->get_position < $self->get_position)){
			$distance_from_previously_allowed_MRE = $self->get_position - $mre->get_position;
		}
	}
	if ($distance_from_previously_allowed_MRE > 200) {
		$distance_from_previously_allowed_MRE = 200;
	}
	
	return $distance_from_previously_allowed_MRE;
}

sub _calculate_bpos0_with_bpos10_feature {
	my ($self) = @_;
	
	my @bindingNTs = split(//,reverse($self->get_binding_vector()));
	return $bindingNTs[0]*$bindingNTs[10];
}

sub _calculate_mre_score_for_version_5_0 {
	my ($self) = @_;
	
	if ($self->is_allowed() == 0) {return 0;}
	
	my $intercept = 1;
	my $MREd = $self->get_distance_from_previously_allowed();
	my $energy = $self->get_energy();
	my $distance_to_closest_end = $self->get_distance_to_closest_end();
	my $binding_category_weight = $self->get_binding_weight();
	my $cdsConservation = $self->get_conservation();
	my $bpos10_with_bpos0 = $self->get_bpos0_with_bpos10();
	my $energy_with_flankingAU = $energy * $self->get_flanking_AU_content();
	
	my @features = ($intercept, $MREd, $energy, $distance_to_closest_end, $binding_category_weight, $cdsConservation, $bpos10_with_bpos0, $energy_with_flankingAU);
	
	my @fit = ( 
	      [-4.7339636467607, 0.00256918841733162, 0.101836744029416, -0.000545496771105737, 0.77098420975976, 0.175658718615213, -0.413248718832565, -0.300829742531461], 
	      [-5.04031851362182, 0.00358742416907102, 0.0672274525343073, -0.000539823285739602, 0.246552430060048, 0.143282655571686, -0.2457169168733, -0.254006496033839], 
	      [-4.63692909324587, 0.0039506073244565, 0.104599376249750, -0.000563592438096935, 0.498908422910284, 0.169436974198114, -0.499431753889347, -0.296247508857163]
	     );
	
	my $score1 = 0;
	my $score2 = 0;
	my $score3 = 0;
	for (my $i=0;$i<@features;$i++) {
		$score1 += $features[$i] * $fit[0][$i];
		$score2 += $features[$i] * $fit[1][$i];
		$score3 += $features[$i] * $fit[2][$i];
# 		print "feature = $features[$i]\n";
	}
	$score1 = MyBio::MyMath->sigmoid($score1);
	$score2 = MyBio::MyMath->sigmoid($score2);
	$score3 = MyBio::MyMath->sigmoid($score3);
# 	print "scores after = $score1\t$score2\t$score3\n";
	
	return ($score1 + $score2 + $score3)/3;
}

1;