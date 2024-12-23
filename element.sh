#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

element_exists() { 
  local element=$1
  local count=$($PSQL "SELECT COUNT(*) FROM elements WHERE atomic_number::text = '$element' OR symbol = '$element' OR name = '$element';")
  if [[ $count -eq 0 ]]; then
    echo "I could not find that element in the database."
    exit
  fi
}

display_element_info(){
  local element=$1
  local element_data=$($PSQL "
    SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
    FROM properties p
    JOIN elements e on p.atomic_number = e.atomic_number
    JOIN types t ON p.type_id = t.type_id
    WHERE e.atomic_number::text = '$element' or e.symbol = '$element' OR e.name = '$element';
    ")

  IFS="|" read -r atomic_number name symbol type atomic_mass melting_point_celsius boiling_point_celsius <<< "$element_data"

  echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point_celsius celsius and a boiling point of $boiling_point_celsius celsius."
}

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
else
  element_exists "$1"
  display_element_info "$1"
fi
