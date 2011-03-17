package Mirna::MockMimat;

use warnings;
use strict;

use Mirna::Mimat;
use _Initializable;

our $VERSION = '1.0';

our @ISA = qw( _Initializable Mirna::Mimat);

# HOW TO INITIALIZE THIS OBJECT
# my $mimatObj = Mirna::Mimat->new({
# 		     NAME         => undef,
# 		     MIMAT        => undef,
# 		     SEQUENCE     => undef,
# 		     SEED         => undef,
# 		     DRIVER       => undef,
# 		     CHR          => undef,
# 		     CHR_START    => undef,
# 		     CHR_STOP     => undef,
# 		     STRAND       => undef,
# 		     EXTRA_INFO   => undef,
# 		     });