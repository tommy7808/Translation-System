#!/bin/sh

#Incidentally we found that sometimes to run the program we needed to use the sudo to command to allow it to run.

echo "Use one or more of the following options:"
echo "\n'help' to display this message"
echo "'src-trg' to set the source and target language"
echo "'set-lines' to set the number of test and validation lines (rest will go into training)"
echo "'test-keywords' to get sentence in test file"
echo "'val-keywords' to get sentence in validation file"
echo "'quit' to terminate program"

running=0 

while test $running -eq 0
do
    read input 

    if test $input = "help"
    then
        #User input options
        echo "Use one or more of the following options:"
        echo "'help' to display this message"
        echo "'src-trg' to set the source and target language"
        echo "'set-lines' to set the number of test and validation lines (rest will go into training)"
        echo "'test-keywords' to get sentence in test file"
        echo "'val-keywords' to get sentence in validation file"
        echo "'quit' to terminate program"
    
    elif test $input = "quit"
        then
            running=1
        
    #Language pair download    
    elif test $input = "src-trg"
        then
            echo "\nWhat would you like your source language to be?"
            read src
            
            echo "\nWhat would you like your target language to be?"
            read trg
            
            echo "\nThe $src to $trg data will now be attempted to download."
            wget -q -O - "https://www.computing.dcu.ie/~dshterionov/Lectures/ca114/2019_2020_project/data/$src-$trg.csv" > $src-$trg.txt
            
            #Checks if downloaded properly(i.e if language pair is available)
            ver=`wc -l < $src-$trg.txt` 
            
            if test $ver -gt 0 
            then
                echo "\nSuccesful download"
            else
                error=0
                while test $error -eq 0
                do
                    rm $src-$trg.txt
                    
                    echo "\nThis language pair is not available."
                    echo "Please re-enter your source language"
                    read src
                    
                    echo "\nPlease re-enter your target language"
                    read trg
                    
                    wget -q -O - "https://www.computing.dcu.ie/~dshterionov/Lectures/ca114/2019_2020_project/data/$src-$trg.csv" > $src-$trg.txt
                    ver=`wc -l < $src-$trg.txt` 
                    
                    if test $ver -gt 0 
                    then
                        echo "\nSuccesful download"
                        error=1
                    fi
                done

            fi

            #Split data into test,validation and training set.
    elif test $input = "set-lines"
        then
            echo "\n What file would you like to split?"
            echo "\n Enter file name in format SRC-TRG.txt, where SRC is source language while TRG is target language"
            read file

            if test -e $file
            then
                echo "\nEnter SRC"
                read src

                echo "\nEnter TRG"
                read trg

                echo "\nHow would you like to split this data?"
                echo "1.Default Settings"
                echo "2.Random"
                echo "3.Input your own settings"
                echo "\nEnter 1,2 or 3" 
                read input2

                #Default settings
                if test $input2 -eq 1
                then
                    head -n 10000 $src-$trg.txt | cut -f 1 > Test_set_$src.txt
                    head -n 10000 $src-$trg.txt | cut -f 2 > Test_set_$trg.txt

                    tail -n 10000 $src-$trg.txt | cut -f 1 > Validation_set_$src.txt
                    tail -n 10000 $src-$trg.txt | cut -f 2 > Validation_set_$trg.txt

                    head -n 90000 $src-$trg.txt | tail -n 80000 | cut -f 1 > Training_set_$src.txt
                    head -n 90000 $src-$trg.txt | tail -n 80000 | cut -f 2 > Training_set_$trg.txt
                    echo "Done"

                #Random spliit
                elif test $input2 -eq 2
                    then
                        train=`shuf -i 20000-100000 -n 1`
                        test=`shuf -i 1-100000 -n 1`
                        validation=`shuf -i 1-100000 -n 1`

                        head -n $test "$src-$trg.txt" | cut -f 1 > Test_set_$src.txt
                        head -n $test "$src-$trg.txt" | cut -f 2 > Test_set_$trg.txt

                        tail -n $validation "$src-$trg.txt" | cut -f 1 > Validation_set_$src.txt
                        tail -n $validation "$src-$trg.txt" | cut -f 2 > Validation_set_$trg.txt

                        head -n 100000 $src-$trg.txt | tail -n $train | cut -f 1 > Training_set_$src.txt
                        head -n 100000 $src-$trg.txt | tail -n $train | cut -f 2 > Training_set_$trg.txt
                        echo "Done"
                else

                    #Specified split
                    if test $input2 -eq 3
                    then
                        echo "How many lines do you want in the Test set?"
                        read t_set
                        head -n $t_set $src-$trg.txt | cut -f 1 > Test_set_$src.txt
                        head -n $t_set $src-$trg.txt | cut -f 2 > Test_set_$trg.txt

                        echo "How many lines do you want in the Validation set?"
                        read v_set
                        tail -n $v_set $src-$trg.txt | cut -f 1 > Validation_set_$src.txt
                        tail -n $v_set $src-$trg.txt | cut -f 2 > Validation_set_$trg.txt

                        echo "How many lines do you want in the Training set?"
                        read tra_set
                        head -n 100000 $src-$trg.txt | tail -n $tra_set | cut -f 1 > Training_set_$src.txt
                        head -n 100000 $src-$trg.txt | tail -n $tra_set | cut -f 2 > Training_set_$trg.txt
                        echo "Done"
                    fi
                fi
            else
                echo "File does not exist"
                break
            fi
    
    #Find sentence in test set using keywords
    elif test $input = "test-keywords"
        then
            echo "\n What language pair would you like to test"
            echo "\n Enter file name in format SRC-TRG.txt, where SRC is source language while TRG is target language"
            read file
            if test -e $file
            then
                echo "\nEnter SRC"
                read src

                echo "\nEnter TRG"
                read trg

                echo "\nWould you like a sentence from the SRC or TRG language?"
                read decision

                if test $decision = "SRC"
                then
                echo "Enter your keyword"
                read key_word
                
                grep $key_word < Test_set_$src.txt
                fi

                if test $decision = "TRG"
                then
                echo "Enter your keyword"
                read key_word
                
                grep $key_word < Test_set_$trg.txt
                fi
            else
                echo "File does not exist."
                running=1
            fi
    
    #Find sentence in validation set using keywords
    elif test $input = "val-keywords"
        then
            echo "\n What file would you like to test"
            echo "\n Enter file name in format SRC-TRG.txt, where SRC is source language while TRG is target language"
            read file
            if test -e $file
            then
                echo "\nEnter SRC"
                read src

                echo "\nEnter TRG"
                read trg

                echo "\nWould you like a sentence from the SRC or TRG language?"
                read decision
                
                if test $decision = "SRC"
                then
                echo "Enter your keyword"
                read key_word
                
                grep $key_word < Validation_set_$src.txt
                fi

                if test $decision = "TRG"
                then
                echo "Enter your keyword"
                read key_word
                
                grep $key_word < Validation_set_$trg.txt
                fi
            else
                echo "File does not exist"
                running=1

            fi
    else
        echo "\nWrong input, enter again."
         

    fi

    #This if statement will only be reached if the program is continued after the language pair has been downloaded
    if test -e $src-$trg.txt
    then
        echo "\nWhat would you like to do next?"
    
        echo "\n'set-lines' to set the number of test and validation lines (rest will go into training)"
        echo "'test-keywords' to get sentence in test file"
        echo "'val-keywords' to get sentence in validation file"
        echo "'quit' to terminate program"
        read input1
        
        if test $input1 = "set-lines"
        then
            echo "\nHow would you like to split this data?"
            echo "1.Default Settings"
            echo "2.Random"
            echo "3.Input your own settings"
            echo "\nEnter 1,2 or 3" 
            read input2
            if test $input2 -eq 1
            then
                head -n 10000 $src-$trg.txt | cut -f 1 > Test_set_$src.txt
                head -n 10000 $src-$trg.txt | cut -f 2 > Test_set_$trg.txt

                tail -n 10000 $src-$trg.txt | cut -f 1 > Validation_set_$src.txt
                tail -n 10000 $src-$trg.txt | cut -f 2 > Validation_set_$trg.txt

                head -n 90000 $src-$trg.txt | tail -n 80000 | cut -f 1 > Training_set_$src.txt
                head -n 90000 $src-$trg.txt | tail -n 80000 | cut -f 2 > Training_set_$trg.txt
                echo "Done"
            elif test $input2 -eq 2
                then
                    train=`shuf -i 20000-100000 -n 1`
                    test=`shuf -i 1-100000 -n 1`
                    validation=`shuf -i 1-100000 -n 1`
                    
                    head -n $test "$src-$trg.txt" | cut -f 1 > Test_set_$src.txt
                    head -n $test "$src-$trg.txt" | cut -f 2 > Test_set_$trg.txt

                    tail -n $validation "$src-$trg.txt" | cut -f 1 > Validation_set_$src.txt
                    tail -n $validation "$src-$trg.txt" | cut -f 2 > Validation_set_$trg.txt

                    head -n 100000 $src-$trg.txt | tail -n $train | cut -f 1 > Training_set_$src.txt
                    head -n 100000 $src-$trg.txt | tail -n $train | cut -f 2 > Training_set_$trg.txt
                    echo "Done"
            else
                if test $input2 -eq 3
                then
                    echo "How many lines do you want in the Test set?"
                    read t_set
                    head -n $t_set $src-$trg.txt | cut -f 1 > Test_set_$src.txt
                    head -n $t_set $src-$trg.txt | cut -f 2 > Test_set_$trg.txt

                    echo "How many lines do you want in the Validation set?"
                    read v_set
                    tail -n $v_set $src-$trg.txt | cut -f 1 > Validation_set_$src.txt
                    tail -n $v_set $src-$trg.txt | cut -f 2 > Validation_set_$trg.txt

                    echo "How many lines do you want in the Training set?"
                    read tra_set
                    head -n 100000 $src-$trg.txt | tail -n $tra_set | cut -f 1 > Training_set_$src.txt
                    head -n 100000 $src-$trg.txt | tail -n $tra_set | cut -f 2 > Training_set_$trg.txt
                    echo "Done"
                fi
            fi
            
        elif test $input1 = "quit"
            then
                break
        
        elif test $input1 = "test-keywords"
            then
                echo "\nWould you like a sentence from the SRC or TRG language?"
                read decision

                if test $decision = "SRC"
                then
                echo "Enter your keyword"
                read key_word
                
                grep $key_word < Test_set_$src.txt
                fi

                if test $decision = "TRG"
                then
                echo "Enter your keyword"
                read key_word
                
                grep $key_word < Test_set_$trg.txt
                fi

                break
        elif test $input1 = "val-keywords"
            then
                echo "\nWould you like a sentence from the SRC or TRG language?"
                read decision
                
                if test $decision = "SRC"
                then
                echo "Enter your keyword"
                read key_word
                
                grep $key_word < Validation_set_$src.txt
                fi

                if test $decision = "TRG"
                then
                echo "Enter your keyword"
                read key_word
                
                grep $key_word < Validation_set_$trg.txt
                fi

                break
        else
            echo "Wrong input"

        fi
    fi
done