TMPFILE=~/temp/tmp.$$

for f in ~/jtag/*.*; do
  sed 's/equation_no_number/equation/g' $f > $TMPFILE
  mv $TMPFILE $f
done


for f in ~/jtag/doc/*.*; do
  sed 's/equation_no_number/equation/g' $f > $TMPFILE
  mv $TMPFILE $f
done


for f in ~/jtag/matlab/*.*; do
  sed 's/equation_no_number/equation/g' $f > $TMPFILE
  mv $TMPFILE $f
done


for f in ~/jtag/matlab/utils/*.*; do
  sed 's/equation_no_number/equation/g' $f > $TMPFILE
  mv $TMPFILE $f
done



for f in /p/learning/klaven/Journals/READY_TO_TAG/jmlr/*.*; do
  sed 's/equation_no_number/equation/g' $f > $TMPFILE
  mv $TMPFILE $f
done


for f in /p/learning/klaven/Journals/READY_TO_TAG/nips_2001/*.*; do
  sed 's/equation_no_number/equation/g' $f > $TMPFILE
  mv $TMPFILE $f
done


for f in /p/learning/klaven/Journals/READY_TO_TAG/nips_2002/*.*; do
  sed 's/equation_no_number/equation/g' $f > $TMPFILE
  mv $TMPFILE $f
done


for f in /p/learning/klaven/Journals/READY_TO_TAG/pami/*.*; do
  sed 's/equation_no_number/equation/g' $f > $TMPFILE
  mv $TMPFILE $f
done






for f in /p/learning/klaven/Journals/TAGGED/jmlr/*.*; do
  sed 's/equation_no_number/equation/g' $f > $TMPFILE
  mv $TMPFILE $f
done


for f in /p/learning/klaven/Journals/TAGGED/nips_2001/*.*; do
  sed 's/equation_no_number/equation/g' $f > $TMPFILE
  mv $TMPFILE $f
done


for f in /p/learning/klaven/Journals/TAGGED/nips_2002/*.*; do
  sed 's/equation_no_number/equation/g' $f > $TMPFILE
  mv $TMPFILE $f
done


for f in /p/learning/klaven/Journals/TAGGED/pami/*.*; do
  sed 's/equation_no_number/equation/g' $f > $TMPFILE
  mv $TMPFILE $f
done



for f in /p/learning/klaven/Journals/TAGGING/jmlr/*.*; do
  sed 's/equation_no_number/equation/g' $f > $TMPFILE
  mv $TMPFILE $f
done


for f in /p/learning/klaven/Journals/TAGGING/nips_2001/*.*; do
  sed 's/equation_no_number/equation/g' $f > $TMPFILE
  mv $TMPFILE $f
done


for f in /p/learning/klaven/Journals/TAGGING/nips_2002/*.*; do
  sed 's/equation_no_number/equation/g' $f > $TMPFILE
  mv $TMPFILE $f
done


for f in /p/learning/klaven/Journals/TAGGING/pami/*.*; do
  sed 's/equation_no_number/equation/g' $f > $TMPFILE
  mv $TMPFILE $f
done



for f in /p/learning/klaven/Journals/TEST_DATA/jmlr/*.*; do
  sed 's/equation_no_number/equation/g' $f > $TMPFILE
  mv $TMPFILE $f
done


for f in /p/learning/klaven/Journals/TEST_DATA/nips_2001/*.*; do
  sed 's/equation_no_number/equation/g' $f > $TMPFILE
  mv $TMPFILE $f
done


for f in /p/learning/klaven/Journals/TEST_DATA/nips_2002/*.*; do
  sed 's/equation_no_number/equation/g' $f > $TMPFILE
  mv $TMPFILE $f
done


for f in /p/learning/klaven/Journals/TEST_DATA/pami/*.*; do
  sed 's/equation_no_number/equation/g' $f > $TMPFILE
  mv $TMPFILE $f
done

