use warnings;
use strict;
use lib '/home/mns/lib/perl/class/dev';

use MyBio::NGS::Experiment;

my $experiment_obj = MyBio::NGS::Experiment->new({XML => 'params.xml'});

my @sub_experiment_names = $experiment_obj->get_subexperiment_names();
foreach my $sub_experiment_name (@sub_experiment_names) {
	print "Sub-Experiment: $sub_experiment_name\n";
	my @sample_names = $experiment_obj->get_sample_names_for_subexperiment($sub_experiment_name);
	foreach my $sample_name (@sample_names) {
		print "\tSample: $sample_name\n";
	}
}

print "\n\n";
foreach my $sub_experiment_name (@sub_experiment_names) {
	print "Sub-Experiment: $sub_experiment_name\n";
	my @samples = $experiment_obj->get_samples_for_subexperiment($sub_experiment_name);
	foreach my $sample (@samples) {
		print "\tSample: name=$sample->{'name'}, type=$sample->{'type'}\n";
	}
}