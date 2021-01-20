#!/usr/bin/pyton
# encoding: utf-8
from flask import Flask
from flask import render_template, redirect, url_for, request
from threading import Thread
import subprocess,os



# Initialise the flask application
app = Flask(__name__)


# Index route
@app.route("/", methods=['GET','POST'])
def index():
    if request.method == 'POST':
        if "scan" in request.form:
            # Threaded mass scan
            run_mass_scan()
            return redirect(url_for('massscan'))

        if "domain" in request.form:
            # Threaded single scan
            domain = request.form.get('domain')
            run_single_scan(domain)
            return redirect(url_for('singlescan', domain=domain))
    return render_template('home.html')

# Do a mass scan on all subdomain
def run_mass_scan():
    thr = Thread(target=run_async_mass_scan, args=[])
    thr.start()
    return thr

# Run a mass async scan
def run_async_mass_scan():
    process = subprocess.Popen(['bash', 'subauto.sh', '&>/dev/null', '&'])
    process.communicate()


# Do a single scan
def run_single_scan(domain):
    thr = Thread(target=run_async_single_scan, args=[domain])
    thr.start()
    return thr
    

# Run a single async scan
def run_async_single_scan(domain):
    process = subprocess.Popen(['bash', 'single.sh', domain, '&>/dev/null', '&'])
    process.communicate()



# Start the scan.
@app.route('/mass-scan')
def massscan():
    try:
        if os.path.isfile('domains.txt'):
            if os.path.isfile("done.txt"):
                return redirect(url_for('results'))
            if os.path.isfile("takeovers"):
                return redirect(url_for('results'))
            else:
                f=open('domains.txt','r+', encoding="utf-8")
                content=f.readlines()
                return render_template('scan.html', len = len(content), domain="")
        else:
            return render_template('scan.html', len = 0, domain="")
    except TypeError:
        return render_template('scan.html', len = 0, domain="")

# Start the single scan.
@app.route('/single-scan/<domain>')
def singlescan(domain):
    try:
        if os.path.isfile('domains.txt'):
            if os.path.isfile("done.txt"):
                return redirect(url_for('results'))
            if os.path.isfile("takeovers"):
                return redirect(url_for('results'))
            else:
                f=open('domains.txt','r+', encoding="utf-8")
                content=f.readlines()
                return render_template('scan.html', len = len(content), domain=domain)
        else:
            return render_template('scan.html', len = 0, domain=domain)
    except TypeError:
        return render_template('scan.html', len = 0, domain=domain)

# Display the results
@app.route('/results')
def results ():
    # Check to see if the session is mine
    if os.path.isfile("takeovers"):
        if os.path.isfile("links"):
            f1=open('takeovers', 'r')
            content=f1.readlines()
            f3=open('links', 'r')
            links=f3.readlines()
            return render_template('results.html', len = len(content), domains=len(content), content=content, links=links)
        else:
            return render_template('results.html', len = 0, domains=0, content="Still Proccessing...", links="")
    else:
        return render_template('results.html', len = 0, domains=0, content="No Subdomain Takeovers Found", links="")
# Run the application 
if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=False, port=5444)