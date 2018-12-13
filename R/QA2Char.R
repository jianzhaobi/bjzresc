# Description:
#     Convert a decimal number to MAIAC quality flags
#
# Usage:
#     QA2Char(num)
#
# Arguments:
#     @ num: a decimal number less than 65536.
#
# Value:
#     It returns an array of strings regarding the MAIAC QA flags

QA2Char <- function(num) {

  if (!is.na(num)) {
    # Decimal to binary
    char <- paste(sapply(strsplit(paste(rev(intToBits(num))),""),`[[`,2),collapse="")
    # Extract the last 16 digits
    char <- substr(char, 17, 32)

    # QA array
    qa.arr <- c(substr(char, 1, 1), # 15 Reserved
                substr(char, 2, 3), # 13-14 Aerosol Model
                substr(char, 4, 4), # 12 Glint Mask
                substr(char, 5, 8), # 8-11 QA AOD
                substr(char, 9, 11), # 5-7 Ajacency Mask
                substr(char, 12, 13), # 3-4 Land Water Snow/Ice Mask
                substr(char, 14, 16)) # 0-2 Cloud Mask
  } else {
    qa.arr <- rep(NA, 7)
  }

  return(qa.arr)
}
