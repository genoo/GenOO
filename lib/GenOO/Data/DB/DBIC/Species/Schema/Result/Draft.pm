# POD documentation - main docs before the code

=head1 NAME

GenOO::Data::DB::DBIC::Species::Schema::Result::Draft - Draft DBIx::Class result class for a sequencing sample database table

=head1 SYNOPSIS

    # This is just a draft class to serve as a reminder of the structure of a hard coded result class for 
    # a sequencing sample database table
    
=cut

# Let the code begin...

package GenOO::Data::DB::DBIC::Species::Schema::Result::Draft;

use Modern::Perl;
use Moose;
use namespace::autoclean;
use MooseX::MarkAsMethods autoclean => 1;

extends 'GenOO::Data::DB::DBIC::Species::Schema::SampleResultBase::v1';

__PACKAGE__->table('Draft');

1;
