### Setup Node environment

Initialize NPM project.json file (manually):

<pre class="file" data-filename="package.json" data-target="replace">

{
    "name": "ksm-sample-js",
    "version": "0.0.1",
    "scripts": {
        "start": "node index.js"
    }
}
</pre>


<pre class="file" data-filename="index.js" data-target="replace">
console.log("Hello World");
</pre>


Execute the code:

`npm start`{{execute}}

Output:

> Hello World

Now that we have working NodeJS application, navigate to the next page to 
create application with KSM JavaScript SDK
