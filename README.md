# Hubot Factoids

A factoids implementation for Hubot, inspired by [oftn-bot](https://github.com/oftn/oftn-bot).

[![Build Status](https://travis-ci.org/therealklanni/hubot-factoids.svg)](https://travis-ci.org/therealklanni/hubot-factoids)

## Installation

`npm install hubot-factoids`

## Configuration

`HUBOT_BASE_URL` _[required]_ - URL of Hubot (ex. http://myhubothost.com:5555/)

`HUBOT_FACTOID_PREFIX` _[optional]_ - prefix character to use for retrieving a factoid (defaults to `!` if unset)

## Commands

### Create/update a factoid

Creates a new factoid if it doesn't exist, or overwrites the factoid value with the new value. Factoids maintain a history (can be viewed via the factoid URL) of all past values along with who updated the value and when.

> **Note:** `<factoid>` can be any string which does not contain `=` or `=~` (these special characters delimit the factoid and its value), although special characters should be avoided.

`hubot learn <factoid> = <details>`

### Inline editing a factoid

If you prefer, you can inline edit a factoid value, using a sed-like substitution expression.

`hubot learn <factoid> =~ s/expression/replace/gi`

`hubot learn <factoid> =~ s/expression/replace/i`

`hubot learn <factoid> =~ s/expression/replace/g`

`hubot learn <factoid> =~ s/expression/replace/`

### Set an alias

An alias will point to the specified pre-existing factoid and when invoked will return that factoid's value.

`hubot alias <factoid> = <factoid>`

### Forget a factoid

Disables responding to a factoid. The factoid is not deleted from memory, and can be re-enabled by setting a new value (its complete history is retained).

`hubot forget <factoid>`

### Get URL to factoid data

Serves a page with the raw JSON output of the factoid data

`hubot factoids`

### Playback a stored factoid value

Retrieve the value of the given factoid.

> **Note:** Hubot should not be directly addressed.

`!<factoid>`
