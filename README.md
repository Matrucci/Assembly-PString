# Assembly Implementation of PString

This is a basic implementation of a pstring in Assembly.

PString is a way to represent a string in a computer. the first byte would be the side of the string and after that an array of characters (up to 255 characters).

## The functionality implemented here supports the following:

 * `char pstrlen(Pstring* pstr)`  - return pstring's length.
 * `Pstring* replaceChar(Pstring* pstr, char oldChar, char newChar)`  - replace all the oldChar with new char in the pstring
 * `Pstring* pstrijcpy(Pstring* dst, Pstring* src, char i, char j)`  - copy the chars in src[i:j] to dst[i:j]
 * `Pstring* swapCase(Pstring* pstr)`  - replace all lower case to upper case and the opposite.
 * `int pstrijcmp(Pstring* pstr1, Pstring* pstr2, char i, char j)`  - compare between src[i:j] to dst[i:j]
