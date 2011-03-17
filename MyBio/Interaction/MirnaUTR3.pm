package MyBio::Interaction::MirnaUTR3;

# Corresponds to a miRNA binding site on the 5'UTR of a gene transcript.

use warnings;
use strict;

use MyBio::Interaction::MRE;
use MyBio::MyMath;

our @ISA = qw(MyBio::Interaction::MRE);

# HOW TO CREATE THIS OBJECT
# my $utr5Obj = Transcript::UTR5->new({
# 		     SPLICE_STARTS    => undef, 
# 		     SPLICE_STOPS     => undef, 
# 		     LENGTH           => undef, 
# 		     SEQUENCE         => undef, 
# 		     ACCESSIBILITY    => undef, 
# 		     CONSERVATION     => undef, 
# 		     EXTRA_INFO       => undef, 
# 		     });

sub _init {
	my ($self, $data) = @_;
	
	$self->{WHERE} = 'UTR3';
	$self->SUPER::_init($data);
	
	return $self;
}

#######################################################################
#############################   Getters   #############################
#######################################################################

sub get_relative_cons {
	my ($self) = @_;
	unless (defined $self->{RELATIVE_CONS}) {
		$self->{RELATIVE_CONS} = $self->_calculate_relative_conservation();
	}
	return $self->{RELATIVE_CONS};
}
sub get_binding_weight {
	my ($self) = @_;
	unless (defined $self->{BINDING_WEIGHT}) {
		$self->{BINDING_WEIGHT} = $self->_return_binding_category_weight();
	}
	return $self->{BINDING_WEIGHT};
}
sub get_accessibility_feature {
	my ($self) = @_;
	unless (defined $self->{ACCESSIBILITY_FEATURE}) {
		$self->{ACCESSIBILITY_FEATURE} = $self->_calculate_accessibility_feature();
	}
	return $self->{ACCESSIBILITY_FEATURE};
}
sub get_distance_from_previously_allowed {
	my ($self) = @_;
	unless (defined $self->{DISTANCE_FROM_PREVIOUS_ALLOWED}) {
		$self->{DISTANCE_FROM_PREVIOUS_ALLOWED} = $self->_find_distance_from_previously_allowed_MRE();
	}
	return $self->{DISTANCE_FROM_PREVIOUS_ALLOWED};
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
#############################   Setters   #############################
#######################################################################


#######################################################################
##########################   Class Methods   ##########################
#######################################################################


#######################################################################
#########################   General Methods   #########################
#######################################################################

sub is_allowed {
	my ($self) = @_;
	
	# This array contains 1 for the allowed new categories and 0 for the non allowed. Note that $allowed[0] corresponds to the intercept and therefore is never read. 
	my @allowed = (1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0);
	
	return $allowed[$self->get_new_category()];
}

sub _calculate_relative_conservation {
# Calculate relative conservation which is the ratio of the MRE conservation versus the corresponding UTR conservation
	my ($self) = @_;
	
	my $MRE_cons_vector = $self->get_conservation();
	my $UTR_cons_vector = $self->get_region->get_conservation();
	my $mustBeConserved=0;
	my $isConserved=0;
	
	#if UTR maf does not exist check all those species that correspond to the miRNA profile
	if (!defined $UTR_cons_vector || $UTR_cons_vector =~ /^0+$/) {
		$UTR_cons_vector = $MRE_cons_vector;
		$UTR_cons_vector =~ s/./1/g;
	}
	
	if ( length($MRE_cons_vector) != length($UTR_cons_vector) ) {
		die "\nFATAL ERROR: The conservation vector of the MRE and the UTR are of different size\n\n";
	}
	
	for (my $i=0;$i<length($MRE_cons_vector);$i++) {
		if (substr($UTR_cons_vector, $i, 1) == 1) {
			$mustBeConserved++;
			if (substr($MRE_cons_vector, $i, 1) == $self->get_driver_binding_count()) {
				$isConserved++;
			}
		}
	}
	
	return ($isConserved/$mustBeConserved);
}

sub _return_binding_category_weight {
	my ($self) = @_;
	
	# note that there are 64 binding categories but the @weights array contains 65 elements (the first element of the array is the intercept - never used)
	my @weights = (-5.83, -9.70, 1.95, -9.77, 1.96, -9.90, 1.11, -9.74, 0.63, 0.38, 0.36, 1.48, -9.73, -9.56, 0.78, 0.13, 0.00, 0.00, 0.00, -9.77, 2.27, 5.14, 1.99, 0.00, -9.73, 0.00, 0.00, 0.00, -9.71, 0.00, 1.02, 0.19, 0.00, -9.74, 3.08, -.80, 2.79, 4.45, 1.75, 0.73, 1.42, 0.09, -0.43, 1.36, -9.73, 0.00, 0.48, 0.09, 0.00, 0.00, 0.00, 2.34, 2.09, -9.76, 1.46, 0.00, 1.18, 0.00, 0.00, 0.00, -9.72, -9.79, 0.72, 0.00, 0.00);
	
	return $weights[$self->get_new_category()];
}

sub _calculate_accessibility_feature {
	my ($self) = @_;
	
	my $accessibility = 0;
	my @accessibility = @{$self->get_region->get_accessibility()};
	
	if ($self->get_position() < @accessibility) {
		$accessibility += $accessibility[$self->get_position()];
		$accessibility += $accessibility[$self->get_position()-1];
	}
	if ($self->get_position()+1 < @accessibility) {
		$accessibility += $accessibility[$self->get_position()+1];
	}
	
	return $accessibility;
}

sub _find_distance_from_previously_allowed_MRE {
	my ($self) = @_;
	
	my $distance_from_previously_allowed_MRE = $self->get_position(); #initialize to distance from start
	my @all_MREs = @{$self->get_mirnaTranscriptInteraction->get_mres()};
	
	for (my $i=0;$i<@all_MREs;$i++) {
		my $mre = $all_MREs[$i];
		if (($mre->get_where eq 'UTR3') && ($mre->is_allowed) && ($mre->get_position < $self->get_position)){
			$distance_from_previously_allowed_MRE = $self->get_position - $mre->get_position;
		}
	}
	if ($distance_from_previously_allowed_MRE > 200) {
		$distance_from_previously_allowed_MRE = 200;
	}
	
	return $distance_from_previously_allowed_MRE;
}

sub _calculate_mre_score_for_version_5_0 {
	my ($self) = @_;
	
	if ($self->is_allowed() == 0) {return 0;}
	
	my $intercept = 1;
	my $distance_to_closest_end = $self->get_distance_to_closest_end();
	my $binding_category_weight = $self->get_binding_weight();
	my $conservation = $self->get_relative_cons();
	my $energy = $self->get_energy();
	my $accessibility = $self->get_accessibility_feature();
	
	my $energy_with_flankingAU = $energy * $self->get_flanking_AU_content();
	my $distance_to_closest_end_with_MREd = $distance_to_closest_end * $self->get_distance_from_previously_allowed();
	my $binding_category_weight_with_conservation = $binding_category_weight * $conservation;
	my $flankingAU_with_conservation = $conservation * $self->get_flanking_AU_content();
	
	my @features = ($intercept, $distance_to_closest_end, $binding_category_weight, $conservation, $energy, $accessibility, $energy_with_flankingAU, $distance_to_closest_end_with_MREd, $binding_category_weight_with_conservation, $flankingAU_with_conservation);
	
	my @fit = (
[-5.71732749907949, -0.00142944429877162, 0.377450469304175, 1.42403988844594, 0.055087088162258, 0.138108133243467, -0.290039619335715, 3.57966921411047*10**(-6), 0.95423945344869, -5.43731707854869], 
[-5.57245318952057, -0.00158834448501625, 0.25143426360604, 2.05520868604791, 0.0624348308575583, 0.111808225330022, -0.349068757947459, 3.76253607406475*10**(-6), 0.649396727693264, -6.0563760797873], 
[-5.45670957483964, -0.00141124388357455, 0.526047890055508, 1.92420581746715, 0.0919330902054809, 0.168588271586038, -0.325767821155670, 3.22542272850305*10**(-6), 0.411990258264903, -3.99658718090310]
	          );
	
	my $score1 = 0;
	my $score2 = 0;
	my $score3 = 0;
	for (my $i=0;$i<@features;$i++) {
		$score1 += $features[$i] * $fit[0][$i];
		$score2 += $features[$i] * $fit[1][$i];
		$score3 += $features[$i] * $fit[2][$i];
	}
	$score1 = MyBio::MyMath->sigmoid($score1);
	$score2 = MyBio::MyMath->sigmoid($score2);
	$score3 = MyBio::MyMath->sigmoid($score3);
	
	return ($score1 + $score2 + $score3)/3;
}



1;