File mainly used to write ALL changes that break backwards compatibility.

Development 2013-10-04
 - Change the interface of GenOO::Data::File::SAM::Record
   The SAM parser had to be optimized and for this the interface of SAM::Record had to be altered.
   Specifically the initiation arguments for the SAM::Record objects have changed from a HashRef
   with all attributes to a single attibute namely "fields" which is an ArrayRef.

Development 2013-05-14
 - The RegionCollection type "DB" is obsolete and has been deleted. It has been replaced by "DBIC".
