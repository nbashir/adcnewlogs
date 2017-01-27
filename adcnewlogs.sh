#!/bin/bash

#adclogs7.sh correct program
#This program will convert a csv file into output files in a certain format.
#usage: This program requires input file as an argument. It will generate two output files in the required format.  
#this program will also give us the number of total visits.
#col1=facility
#col2=mr
#medcode= visits(121,5102),(transp(600.2003)
#col3=quantity
#col4=day
#col5=month format m/dd/yyyy
#col6=empty
#col7=price always=0

function chkfilename {
local filename 
filename=$1
#if [[ $filename =~ \.[0-1][1-9]20[0-9][0-9]\.csv$ ]]; then
if [[ $filename == *.[0-1][0-9]20[0-9][0-9].csv ]]; then
  return 0
else
  return 1
fi
}

#file name format =adclogs.monthyear.csv
inputpath=$1
inputd=$(dirname $inputpath) #strips last component from file name.
outputd=$inputd
inputf=$(basename $inputpath ) #basename will give the file name.
if ! chkfilename $inputf; then
  echo >&2 "filename \"$inputf\" is not valid because it does not have MMYYYY month-year pattern e.g adclogs.052015.csv"
  exit 1
fi
temp=${inputf%.*}  #string operation will remove first part before the .e.g adc.2015.csv will give 052015.csv only 
monthyear=${temp#*.} # string operation wil remove after the . and will return 052015 will remove csv
month=${monthyear:0:2} #will start from the first postion and only give 2 character in this case will give us back 05
year=${monthyear:2:4} # will start from the postion 2 will return 4 character
exec <$inputpath #exec opens the file 
declare -A medcodes=([MED]=121 [MMC]=5102 [MLTC]=5102) #associative array
declare -A transportcodes=([MED]=600 [MMC]=600 [MLTC]=2003) #associative array
#echo "transportcodes ${tansportcodes[*]}"
declare -a data
declare -a transportdata
adcvisitoutf=adcout.visit.$monthyear.csv
adcvisitoutpath=$outputd/$adcvisitoutf
adctranspoutf=adcout.transp.$monthyear.csv
adctranspoutpath=$outputd/$adctranspoutf
facility=2
numdayscol=31
firstdaycolindx=3
if [[ -e $adctranspoutpath ]]; then # -e , if file exists
  rm $adctranspoutpath 
fi
if [[ -e $adcvisitoutpath ]]; then
  rm $adcvisitoutpath
fi
Gtotalquatity=0
price=0
read line #read the heading
declare -i quantity
totalquantity=0
totalvisits=0
while IFS=, read -a data; do
  unset IFS
  totalvisits=${data[34]}
  n=${#data[*]}
mr=${data[1]}
  data[n-1]=${data[n-1]%$'\r'}
if [[ -z ${data[0]} && -n ${data[34]} ]]; then
echo "last value ${data[34]}"
fi
  if [[ -z $mr ]]; then
    continue
  fi
  inscode=${data[2]}
  #echo "medcod=${medcodes[$inscode]}"
  for((i=firstdaycolindx; i<(firstdaycolindx+numdayscol); ++i));do
    quantity=1
    visit=${data[$i]}
    day=$(($i-2))
    if [[ $visit == 1 ]]; then
      totalquantity=$((totalquantity + 1))
     # echo "quantity \"$quantity\"" >>$adcvisitoutpath
      #printf "%d,%d,%d,%d,%.2d,%d/%d/%d,,%d\n" $facility $mr ${medcodes[$inscode]} $quantity $day $month $day $year $price >>$adcvisitoutpath
      printf "%d,%d,%d,%d,%.2d,%d/%d/%d,,%d\n" $facility $mr ${medcodes[$inscode]} $quantity $((10#$day)) $((10#$month)) $day $year $price >>$adcvisitoutpath
      if [[ $inscode == MLTC ]]; then
        quantity=2
      fi
      printf "%d,%d,%d,%d,%.2d,%d/%d/%d,,%d\n" $facility $mr ${transportcodes[$inscode]} $quantity $((10#$day)) $((10#$month)) $((10#$day)) $year $price >>$adctranspoutpath
    fi
  done
done
#echo "totalquantity $totalquantity "     
#echo "created output files $adcvisitoutpath $adctranspoutpath"
#wctotalvisit=$(wc -l $adcvisitoutpath) 
#wctotaltransp=$(wc -l $adctranspoutpath)
#echo "$wctotaltransp $wctotalvisit "
#totalvisit=${wctotalvisit% *}
#totaltransp=${wctotaltransp% *}
#echo "totlvisit $totalvisit"
#echo " totaltransp $totaltransp"
grandtotalvisits=$totalvisits
#echo "grand total of visits = $grandtotalvisits"
#if [[ $totaltransp == $totalvisit && $totalvisit == $totalquantity ]]; then
  echo " GRAND TOTAL is $totalquantity"
#else
 # echo " ERROR"
#fi

