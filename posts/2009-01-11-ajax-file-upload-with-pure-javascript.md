--------------------------------------------
title: Ajax file upload with pure JavaScript
author: Ionuț G. Stan
date: January 11, 2009
--------------------------------------------


I don't know about you, but there's one little thing I've always hated about Ajax.
The impossibility of file uploading. I still remember the ugly day when I
discovered the terrible truth. There was no chance on earth you could send a file
using an `XMLHttpRequest`, thus workarounds appeared. Google made use of a hidden
iframe to imitate such an asynchronous call for their Gmail service, and later on,
Flash based uploaders appeared. Things are though going forward.

Firefox 3 introduced a new <abbr title="Application Programming Interface">API</abbr>,
that few people know about, which allows JavaScript to read local files selected
by an user from a form file-upload dialog. A copy of Firefox 3 with default settings
offers full access to this new programming interface. So we'll embrace the challenge
and write a little JavaScript uploader on top of this new
<abbr title="Application Programming Interface">API</abbr>.


Goal
----
In this tutorial we'll write a little application that is able to read and upload
local files to a remote web server using an asynchronous
<abbr title="HyperText Transfer Protocol">HTTP</abbr> request. The whole application
consists of three parts:

 - the client side comprised of JavaScript, <abbr title="HyperText Markup Language">HTML</abbr>
   and a little <abbr title="Cascading Style Sheets">CSS</abbr>
 - the server side script, written in PHP
 - the communication channel in between them, old good <abbr title="HyperText Transfer Protocol">HTTP</abbr>

We'll start with the JavaScript side, as I'm sure you're eager to find about the
new file access <abbr title="Application Programming Interface">API</abbr>, then
we'll review the `XMLHttpRequest` object as available in Firefox version 3 (it got
enhanced with a new method). After the client-side part follows explanations for
the server-side script, written in PHP, continued with a little summary over the
<abbr title="HyperText Transfer Protocol">HTTP</abbr> protocol concerning data
transmission and <abbr title="HyperText Markup Language">HTML</abbr> forms.
Finally, we'll put all these together to build a powerful asynchronous file
uploader.


The Firefox file upload <abbr title="Application Programming Interface">API</abbr>
---------------------------
When Firefox 3 has been launched in June this year, we heard a lot about the
improvements it brought to the web development field by further implementing
existing standards and technologies like <abbr title="HyperText Markup Language">HTML</abbr>,
<abbr title="Cascading Style Sheets">CSS</abbr> and JavaScript. One thing I
have never seen mentioned was the interface for reading local files, provided
the file is chosen by the user through an <abbr title="HyperText Markup Language">HTML</abbr>
file input element. For example, a simple Google search for getAsBinary, one of
the new methods in the <abbr title="Application Programming Interface">API</abbr>,
will give you few results, even when counting the false positives (such a false
positive is related to ColdFusion which has a similar method name, and results
comprising information about it are preponderant). That surprises me a lot as,
in my opinion, it is a huge step forward in building more powerful web applications.
Actually, there is [someone][1] that wrote about it in May 2008. Alas the news
hasn't spread. With this new <abbr title="Application Programming Interface">API</abbr>,
each input element (not only file input elements), is given a property called files.
This property is our gateway to reading local files. When the type attribute of
the input element isn't file, the value of the files property is null. On the
other hand, for input elements whose type attribute is file, the files property
is of type `FileList` and resembles a `NodeList` object returned by, let's say,
`document.getElementsByTagName()`. You may access it as if it were an `Array`
and has the following properties and methods:

 - `length`
 - `item(index)`

Each element in the files property is a File element that exposes the following
properties and methods:

 - `fileName`
 - `fileSize`
 - `getAsBinary()`
 - `getAsText(encoding)`
 - `getAsDataURL()`

Those two lists above are all there is to know about the
<abbr title="Application Programming Interface">API</abbr> for reading local
files. There is nothing more about it. No security restrictions, no special
configurations. As I'm sure the files property itself poses no problem in
understanding its interface let's review the contained file objects with a little
script. You may want to download [Firebug][2] in order to get a thorough
understanding of the following exploration. Here's the code that we'll use:

~~~ {.html}
<!DOCTYPE html>

<html>
<head>
<title>JavaScript file upload</title>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<script type="text/javascript">
var upload = function() {
    var photo = document.getElementById("photo");
    return false;
};
</script>
</head>
<body>

<form action="/" method="post" onsubmit="return upload();">
  <fieldset>
    <legend>Upload photo</legend>
    <input type="file" name="photo" id="photo">
    <input type="submit" value="Upload">
  </fieldset>
</form>

</body>
</html>
~~~

The `fileName` property gives us the name of the picked up file, but not the
absolute path on the filesystem, just the basename. Modify the above source code
above so that the JavaScript part now becomes:

~~~ {.javascript}
var upload = function() {
    var photo = document.getElementById("photo");
    // the file is the first element in the files property
    var file = photo.files[0];

    console.log("File name: " + file.fileName);
    console.log("File name: " + file.fileSize);

    return false;
};
~~~

The `getAsBinary()` method will read the contents of the file and return them in
binary representation. If you select a binary file, an image for example, you
should see some weird characters, question marks or even rectangles in the alert,
this is how Firefox represents the bytes contained in the file. For a text file
it will simply output its text.

The `getAsText(encoding)` method will return the contents as a string of bytes
encoded depending on the encoding parameter. This is by default UTF-8, but the
encoding parameter it's not really optional. You still have to pass some value.
An empty string will do it just fine:

~~~ {.javascript}
var upload = function() {
    var photo = document.getElementById("photo");
    // the file is the first element in the files property
    var file = photo.files[0];

    console.log("File name: " + file.fileName);
    console.log("File size: " + file.fileSize);
    console.log("Binary content: " + file.getAsBinary());
    console.log("Text content: " + file.getAsText(""));
    // or
    // console.log("Text content: " + file.getAsText("utf8"));

    return false;
};
~~~

Finally, the `getAsDataURL()` method, a very interesting and very useful one,
will return the file contents in a format ideally suited for, let's say, the src
attribute of an `IMG` tag. Of course, this will work as we're in Firefox right
now, so let's add a `IMG` tag to the <abbr title="HyperText Markup Language">HTML</abbr>
source and the appropriate JavaScript code to make this work:

~~~ {.html}
<!DOCTYPE html>

<html>
<head>
<title>JavaScript file upload</title>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<script type="text/javascript">
var upload = function() {
    var photo = document.getElementById("photo");
    var file = photo.files[0];

    console.log("File name: " + file.fileName);
    console.log("File size: " + file.fileSize);
    console.log("Binary content: " + file.getAsBinary());
    console.log("Text content: " + file.getAsText(""));

    var preview = document.getElementById("preview");
    preview.src = file.getAsDataURL();

    return false;
};
</script>
</head>
<body>

<form action="/" method="post" onsubmit="return upload();">
  <fieldset>
    <legend>Upload photo</legend>
    <input type="file" name="photo" id="photo">
    <input type="submit" value="Upload">
    <hr>
    <img src="" alt="Image preview" id="preview">
  </fieldset>
</form>

</body>
</html>
~~~

More information about the new <abbr title="Application Programming Interface">API</abbr>
can be found on their dedicated pages on Mozilla Developer Center:

 - [https://developer.mozilla.org/en/nsIDOMFileList][3]
 - [https://developer.mozilla.org/en/nsIDOMFile][4]


### Some extra information
You may wonder why an array of files for just one input element. It turns out
that [<abbr title="Request for Comments">RFC</abbr> 1867][5], concerning form-based
file uploads, specifies that a file input element allows its size attribute to
receive a complex value:

> The `SIZE` attribute might be specified using `SIZE=width,height`,
> where width is some default for file name width, while height is
> the expected size showing the list of selected files.  For example,
> this would be useful for forms designers who expect to get several
> files and who would like to show a multiline file input field in
> the browser (with a "browse" button beside it, hopefully).  It
> would be useful to show a one line text field when no height is
> specified (when the forms designer expects one file, only) and to
> show a multiline text area with scrollbars when the height is
> greater than 1 (when the forms designer expects multiple files).

None of the browsers I tested this in seems to obey the <abbr title="Request for Comments">RFC</abbr>,
nevertheless this should be the reason for which the files property is an
array-like object.


The XMLHttpRequest object
-------------------------
Now that we're able to read local files, we need a way to get this data, over the
network, to the server. As we're aiming for an asynchronous data transmission,
an `XMLHttpRequest` object should do the job just fine. Unfortunately, its `send()`
method isn't that reliable in sending binary data. For this reason, along with
the local file access interface, Firefox 3 brought a new method to the
`XMLHttpRequest` object: `sendAsBinary(data)`. Just as the `send()` method, the
new one takes a single argument, a string, which is converted to a string of
single-byte characters by truncation (removing the high-order byte of each
character), according to the [documentation][6]. The difference, a very important
one, is that, as long as `send()` knows how to process an
<abbr title="Uniform Resource Locator">URL</abbr> query string, `sendAsBinary()`
expects a totally different format in order to be useful for the server-side end
of the application, but we'll talk about this a little bit later. Let's just
write a little JavaScript skeleton, that we'll use when assembling together all
the pieces of the application:

~~~ {.javascript}
send: function () {
    var boundary = this.generateBoundary();
    var xhr = new XMLHttpRequest;

    xhr.open("POST", this.form.action, true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            alert(xhr.responseText);
        }
    };
    var contentType = "multipart/form-data; boundary=" + boundary;
    xhr.setRequestHeader("Content-Type", contentType);

    for (var header in this.headers) {
        xhr.setRequestHeader(header, headers[header]);
    }

    // here's our data variable that we talked about earlier
    var data = this.buildMessage(this.elements, boundary);

    // finally send the request as binary data
    xhr.sendAsBinary(data);
}
~~~

As you see, there's an undefined variable in the above snippet, data, which
remains to be defined after we review the mechanism behind files upload over
<abbr title="HyperText Transfer Protocol">HTTP</abbr>. For the moment though, I
want to talk about the server-side part, as it will guide us in choosing the
appropriate strategy for sending binary information.


The server-side script
----------------------
PHP, as well as several web frameworks made on top of other languages, offers
different access points for reading POST data containing uploaded files and POST
data containing just simple values. In PHP there are two predefined arrays giving
you access to simple POST data, the `$_POST` array, and another one for accessing
files sent to the server, the `$_FILES` array. It is thus wise to build a
client-side script able to send information that PHP would read as from a classical
request issued with an <abbr title="HyperText Markup Language">HTML</abbr> form:
our uploaded files would appear as elements inside the `$_FILES` array and additional
values as elements inside the `$_POST` array. Under these circumstances we can
write the PHP script to test that our JavaScript client is performing well:

~~~ {.php}
<?php

print_r($_FILES);
print_r($_POST);
~~~

That's all we need on the server. Although simple this we'll give us valuable
feedback about the sent data. The PHP script should list our uploaded files
inside the `$_FILES` array and any additional form data (like text `INPUT` or
`SELECT` element) inside the `$_POST` array.


Form data over <abbr title="HyperText Transfer Protocol">HTTP</abbr> theory
--------------------------
As we saw, PHP treats POST-ed files differently than ordinary form field values,
so it's only natural to ask ourselves what's the "clue" that helps PHP tell apart
one from the other.

First of all, every <abbr title="HyperText Markup Language">HTML</abbr> form
element out there has an optional attribute called *enctype*, with a default
value of `application/x-www-form-urlencoded`. This is actually a
<abbr title="Multipurpose Internet Mail Extensions">MIME</abbr> type value
specifying the encoding to be used by the web browser when sending form data. It
also guides the web server script in decoding that data as the encoding is sent
by the browser to the server in the form of an <abbr title="HyperText Transfer Protocol">HTTP</abbr>
header, called `Content-Type`. For a default enctype value, form data is sent as
<abbr title="American Standard Code for Information Interchange">ASCII</abbr>
characters, <abbr title="Uniform Resource Locator">URL</abbr> encoded when necessary.
On the other hand, when uploading files, we need to change the enconding to
`multipart/form-data`. Cloning this basic form functionality inside our JavaScript
client is what we should do. Let's modify the earlier script so that it sends
such a `multipart/form-data` header:

~~~ {.javascript}
var xhr = new XMLHttpRequest;
xhr.onreadystatechange = function() {
    if (xhr.readyState === 4) {
        alert(xhr.responseText);
    }
};
xhr.setRequestHeader("Content-Type", "multipart/form-data");
xhr.sendAsBinary(data);
~~~

<abbr title="Request for Comments">RFC</abbr> 1867, regarding form-based file
uploads, dictates that an extra parameter is required for the `Content-Type`
header when its value is `multipart/form-data`. It is called boundary and its
presence it's very logical. The multipart word inside the header means the sent
request is formed of multiple parts (obviously), so there must be something to
separate those parts. This thing is the boundary parameter which value must be
a string of characters that shouldn't be found inside any of the form values we
send, otherwise the request will get garbled. Once again, let's modify the script
to reflect this requirement.

~~~ {.javascript}
var xhr = new XMLHttpRequest;
xhr.onreadystatechange = function() {
    if (xhr.readyState === 4) {
        alert(xhr.responseText);
    }
};

/*
 * The value of the boundary doesn't matter as long as no other structure in
 * the request contains such a sequence of characters. We chose, nevertheless,
 * a pseudo-random value based on the current timestamp of the browser.
 */
var boundary = "AJAX--------------" + (new Date).getTime();
var contentType = "multipart/form-data; boundary=" + boundary;
xhr.setRequestHeader("Content-Type", contentType);
xhr.sendAsBinary(data);
~~~

Next, let's talk about the structure of the parts comprised in the request. Each
of these is like a little request on its own. Each has its own headers structure
and body.

The mandatory header, every part must have, is called `Content-Disposition` and
its value should be form-data followed by an additional parameter called name,
which represents the name of the form input that holds the data. In case of parts
holding uploaded files, a second parameter must also be present, called filename.
This is the name of the file as it was on the user's computer. Not the absolute
path, just the basename (for example, monkey.png). Parameter values are enclosed
inside double quotes. A little example:

    Content-Disposition: form-data; name="photo"; filename="monkey.png"

In the case of files, a second header must is also needed. It is called
`Content-Type` and specifies the <abbr title="Multipurpose Internet Mail Extensions">MIME</abbr>
type of the file. This may be deduced by reading the file extension or the source
of the file. Anyway, a general value of `application/octet-stream` is perfectly
acceptable:

    Content-Disposition: form-data; name="photo"; filename="monkey.png"
    Content-Type: image/png

As per the [standards][7], every such header should end with two characters, a
carriage return and a new line: `CR` and `LF`. The last header doubles this
sequence (i.e. it ends with `CRLFCRLF`).

Following the headers is the body which consists of the form field value. I'll
illustrate with a simple text file upload, although it could be any type of file.
The text inside the file is "my random notes about web programming":

    Content-Disposition: form-data; name="notes"; filename="my_notes.txt"
    Content-Type: text/plain

    my random notes about web programming

Finally I'll give you a final example with both the <abbr title="HyperText Markup Language">HTML</abbr>
markup of the form as well as a fictional request from that form:

~~~ {.html}
<form action="upload.php" method="post" enctype="multipart/form-data">
  <fieldset>
    <legend>Upload photo</legend>
    <label for="image_name">Image name:</label>
    <input type="text" name="image_name" id="image_name">
    <select name="image_type">
      <option>Family</option>
      <option>Work</option>
      <option>Vacation</option>
    </select>
    <input type="file" name="photo" id="photo">
    <input type="submit" value="Upload">
  </fieldset>
</form>
~~~

The issued request could be:

    Content-Type: multipart/form-data; boundary=RANDOM_STRING_BOUNDARY
    --RANDOM_STRING_BOUNDARY
    Content-Disposition: form-data; name="image_name"

    Monkey
    --RANDOM_STRING_BOUNDARY
    Content-Disposition: form-data; name="image_type"

    Vacation
    --RANDOM_STRING_BOUNDARY
    Content-Disposition: form-data; name="photo"; filename="monkey.png"
    Content-Type: image/png

    [ here would be the png file in binary form ]
    --RANDOM_STRING_BOUNDARY--

In case you didn't noticed, the boundary, when used in between the parts is
prepended with two hyphens and the last one appended with also two hyphens. Don't
forget about this, it's an ugly source of bugs.


Encapsulating the JavaScript logic
----------------------------------
At this point we know all the parts to successfully build a pure JavaScript file
uploader, which we're going to implement as an object. Here's the basic structure
of the constructor and its prototype:

~~~ {.javascript}
/**
 * @param DOMNode form
 */
var Uploader = function(form) {
    this.form = form;
};

Uploader.prototype = {
    /**
     * @param Object HTTP headers to send to the server, the key is the
     * header name, the value is the header value
     */
    headers : {},

    /**
     * @return Array of DOMNode elements
     */
    get elements() {},

    /**
     * @return String A random string
     */
    generateBoundary: function() {},

    /**
     * Constructs the message as discussed in the section about form
     * data transmission over HTTP
     *
     * @param Array elements
     * @param String boundary
     * @return String
     */
    buildMessage : function(elements, boundary) {},

    /**
     * @return null
     */
    send : function() {}
};
~~~

In case you didn't understand the `elements()` construct, this is called a getter
and is supported by the latest versions of Firefox, Opera, Safari and Chrome.
A setter form is also provided. You can find more about these on [Mozilla Developer
Center][8].

We should fill the above methods, so let's start with the `send()` method because
we already wrote much of it in a previous sections of the tutorial:

~~~ {.javascript}
/**
 * @return null
 */
send : function() {
    var boundary = this.generateBoundary();
    var xhr = new XMLHttpRequest;

    xhr.open("POST", this.form.action, true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            alert(xhr.responseText);
        }
    };
    var contentType = "multipart/form-data; boundary=" + boundary;
    xhr.setRequestHeader("Content-Type", contentType);

    for (var header in this.headers) {
        xhr.setRequestHeader(header, headers[header]);
    }

    // here's our data variable that we talked about earlier
    var data = this.buildMessage(this.elements, boundary);

    // finally send the request as binary data
    xhr.sendAsBinary(data);
}
~~~

In addition to what we had earlier we have now introduced an iteration that allows
us to send additional headers without modifying the prototype itself. We have also
defined the variable we talked about earlier, data, which holds the source of the
<abbr title="HyperText Transfer Protocol">HTTP</abbr> request. It holds the value
returned by a call to a method whose only purpose is to build an
<abbr title="HyperText Transfer Protocol">HTTP</abbr> compliant request for file
uploads. Here's its source:

~~~ {.javascript}
/**
 * @param Array elements
 * @param String boundary
 * @return String
 */
buildMessage : function(elements, boundary) {
    var CRLF = "\r\n";
    var parts = [];

    elements.forEach(function(element, index, all) {
        var part = "";
        var type = "TEXT";

        if (element.nodeName.toUpperCase() === "INPUT") {
            type = element.getAttribute("type").toUpperCase();
        }

        if (type === "FILE" && element.files.length > 0) {
            var fieldName = element.name;
            var fileName = element.files[0].fileName;

            /*
             * Content-Disposition header contains name of the field
             * used to upload the file and also the name of the file as
             * it was on the user's computer.
             */
            part += 'Content-Disposition: form-data; ';
            part += 'name="' + fieldName + '"; ';
            part += 'filename="'+ fileName + '"' + CRLF;

            /*
             * Content-Type header contains the mime-type of the file
             * to send. Although we could build a map of mime-types
             * that match certain file extensions, we'll take the easy
             * approach and send a general binary header:
             * application/octet-stream
             */
            part += "Content-Type: application/octet-stream";
            part += CRLF + CRLF; // marks end of the headers part

            /*
             * File contents read as binary data, obviously
             */
            part += element.files[0].getAsBinary() + CRLF;
       } else {
            /*
             * In case of non-files fields, Content-Disposition
             * contains only the name of the field holding the data.
             */
            part += 'Content-Disposition: form-data; ';
            part += 'name="' + element.name + '"' + CRLF + CRLF;

            /*
             * Field value
             */
            part += element.value + CRLF;
       }

       parts.push(part);
    });

    var request = "--" + boundary + CRLF;
        request+= parts.join("--" + boundary + CRLF);
        request+= "--" + boundary + "--" + CRLF;

    return request;
}
~~~

Although it looks complex, it has a fair amount of comments so that you won't
have hard times understanding what it does. It simply iterates over an array of
<abbr title="HyperText Markup Language">HTML</abbr> elements and for each such an
element constructs a different message depending whether the element is a file
upload input or not. It pushes this message into an internal array, which is
finally joined using the boundary sent as an argument inside the `send()` method.

Here follows the source of the `elements()` getter, used in `send()`:

~~~ {.javascript}
/**
 * @return Array
 */
get elements() {
    var fields = [];

    // gather INPUT elements
    var inputs = this.form.getElementsByTagName("INPUT");
    for (var l=inputs.length, i=0; i
        fields.push(inputs[i]);
    }

    // gather SELECT elements
    var selects = this.form.getElementsByTagName("SELECT");
    for (var l=selects.length, i=0; i
        fields.push(selects[i]);
    }

    return fields;
}
~~~

The snippet above grabs all the `INPUT` and `SELECT` elements inside the `FORM`
element associated with the `Uploader` object. These elements are eventually
returned into a unified array. There are, however no checks on these elements,
like filtering disabled controls. Furthermore, the <abbr title="Request for Comments">RFC</abbr>
specifies that a client should send form data in the same order it was rendered
in the user agent. For keeping the examples as short as I could, the method above
doesn't take care of that, but the code inside the accompanying archive does.

The final piece of code left for presentation is the `generateBoundary()` method
which must return a string unique in the body of our request. For our simple
example though, the method below should be just fine:

~~~ {.javascript}
/**
 * @return String
 */
generateBoundary: function() {
    return "AJAX-----------------------" + (new Date).getTime();
}
~~~

The code inside is building a string based on the current timestamp to which some
other characters are prepended. I'm using the uppercased word "AJAX" and some dashes,
but this prefix isn't mandatory, the only condition that must be met is that the
result of `generateBoudary()` should not appear anywhere else in out request except
for the boundary placeholders.

Finally, the headers property of our object remains like it was in the skeleton.
It is there so that you can append additional headers to the request, for example:

~~~ {.javascript}
var upl = new Uploader(form);
upl.headers["X-Requested-With"] = "XMLHttpRequest";
~~~

Save the source of the Uploader object in a file called "uploader.js", we'll use
it in a few moments.


Putting it all together
-----------------------
Let's now write the final <abbr title="HyperText Markup Language">HTML</abbr>
source and save it inside a file called "index.html". Aside the markup, the code
below introduces some event listeners for the "Upload" and "Preview" button:

~~~ {.html}
<!DOCTYPE html>

<html>
<head>
<title></title>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<meta http-equiv="imagetoolbar" content="false">
<meta http-equiv="imagetoolbar" content="no">
<link rel="stylesheet" type="text/css" href="css/default.css">
<script type="text/javascript" src="uploader.js"></script>
<script type="text/javascript">
window.addEventListener("load", function() {
    var input = document.getElementById("photo");
    var img = document.getElementById("img");
    var previewBtn = document.getElementById("preview");
    previewBtn.addEventListener("click", function() {
        img.src = input.files[0].getAsDataURL();
    }, false);

    var form = document.getElementsByTagName("form")[0];
    var uploader = new Uploader(form);
    var uploadBtn = document.getElementById("upload");

    uploadBtn.addEventListener("click", function() {
        uploader.send();
    }, false);

}, false);
</script>
</head>
<body>

<form action="upload.php" method="post"
      enctype="multipart/form-data"
      onsubmit="return false;">
  <fieldset>
    <legend>Upload photo</legend>
    <label for="image_name">Image name:</label>
    <input type="text" name="image_name" id="image_name"> |
    <label for="image_type">Image type:</label>
    <select name="image_type" id="image_type">
      <option>JPEG</option>
      <option>PNG</option>
      <option>GIF</option>
    </select> |
    <input type="file" name="photo" id="photo">
    <input type="submit" value="Upload" id="upload">
    <input type="submit" value="Preview" id="preview">
    <hr>
    <img src="" alt="image preview" id="img">
  </fieldset>
</form>

</body>
</html>
~~~

Now create another file, save it as upload.php, and write inside it the code we
presented in the server-side section of the tutorial:

~~~ {.php}
<?php

print_r($_FILES);
print_r($_POST);
~~~

That's all. You may now test the application, which will hopefully work from the
first run. Don't forget to install Firebug to inspect what's happening behind the
scenes.


Conclusion
----------
There's probably a lot to be discussed around this new feature Mozilla introduced
along with Firefox 3. Some may wonder if it is worth using it. Well, as ever, it
depends on what you want to accomplish. You may employ fall back techniques (like
the iframe workaround) in order to have support for other browsers, if that is
your concern. If you want a fancy <abbr title="User Interface">UI</abbr> though,
a Flash based uploader may be better. But don't forget, the new
<abbr title="Application Programming Interface">API</abbr> is not all about
uploading. You may now read local files and process them right there in the
browser. You may resize images, parse <abbr title="eXtensible Markup Language">XML</abbr>
or do whatever your imagination limits are. In my opinion this is a huge step
forward for web development and I'd really like other browser vendors to implement
this <abbr title="Application Programming Interface">API</abbr> as [the standards][9]
seem to be abandoned. Rich Internet applications would be far more powerful and
their responsiveness further increased.


[1]: http://soakedandsoaped.com/articles/read/firefox-3-native-ajax-file-upload
[2]: https://addons.mozilla.org/en-US/firefox/addon/1843
[3]: https://developer.mozilla.org/en/nsIDOMFileList
[4]: https://developer.mozilla.org/en/nsIDOMFile
[5]: http://www.faqs.org/rfcs/rfc1867.html
[6]: https://developer.mozilla.org/en/XMLHttpRequest#sendAsBinary%28%29
[7]: http://www.faqs.org/rfcs/rfc822.html
[8]: https://developer.mozilla.org/en/Core_JavaScript_1.5_Guide/Creating_New_Objects/Defining_Getters_and_Setters
[9]: http://www.w3.org/TR/file-upload/
