File mainly used to write ALL changes that break backwards compatibility.

2015-09-30 version:1.5.0
 - For a DBIC RegionCollection all the "*overlap*" methods were deprecated.
   However for the DoubleHashArray RegionCollection this was not the case and
   there were discrepancies of methods actually calling overlap when contain
   was requested. These inconsistencies have now been fixed and all the
   "*overlap*" methods have been marked as deprecated.

 - Skip genes whose transcripts do not overlap. In a GTF file there are cases
   in which the transcripts of a gene do not overlap. Previously, a separate
   gene entry for each overlapping set of its transcripts was created. We no
   longer allow this. It seems that these genes are poorly annotated and
   therefore are now skipped entirely.

2013-10-04
 - Change the interface of GenOO::Data::File::SAM::Record
   The SAM parser had to be optimized and for this the interface of SAM::Record had to be altered.
   Specifically the initiation arguments for the SAM::Record objects have changed from a HashRef
   with all attributes to a single attibute namely "fields" which is an ArrayRef.

2013-05-14
 - The RegionCollection type "DB" is obsolete and has been deleted. It has been replaced by "DBIC".
