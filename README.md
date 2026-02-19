# Wish Registry

**Author:** Bryce Campbell

**License:** See LICENSE

**Description:** iOS port of a CLI application that I wrote in Rust that can be used to generate a wish list in HTML.

**Version:** 0.1

## Notes

This application has been tested on iOS 26. It is not currently known how well it will run elsewhere.

### Questions

1. <dl>
  <dt style="font-weight:bold">Why create this application when there are so many others options for wish lists?</dt>
  <dd>
    While there are indeed many wish list applications out there, 
    they all seem to rely on the Internet, which is fine if everything you want is online to begin with, but I would rather not deal with the complications involved.
    Also, I currently make my own wish lists by hand via the following process:

  * Create a list</li>
  * Generate and clean up HTML</li>
  * Add notes to HTML</li>
  * Add styles to the HTML, to make it friendly for touch screen and print

  Even though I don't intend for this application to do all of that, I do want it to be able to generate a HTML list with the notes included, 
  so that I can focus on adding the appropriate style rules myself.
  
  However, this application does include some styling stuff in the HTML export that I like adding in, to make the HTML more readable on modern phones.

  Other than that, I wanted to both be able to challenge myself a bit more and even make it so that I do not need to rely on the [original program](https://github.com/bryceac/wlist) I wrote
  </dd>
</dl>
