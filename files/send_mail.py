#!/usr/bin/python
# Python code for sending mail with attachments
 
# libraries to be imported
import smtplib
import argparse, os
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders

def send_mail (
	file_name,
	receiver,
	sender,
):
	SMTPSERVER = "localhost"

	# instance of MIMEMultipart
	msg = MIMEMultipart()
 
	# storing the senders email address  
	msg['From'] = sender
 
	# storing the receivers email address 
	msg['To'] = receiver
 
	# storing the subject 
	msg['Subject'] = "OpenVPN Configuration"
 
	# string to store the body of the mail
	body = "Please find your OpenVPN configuration attached"
 
	# attach the body with the msg instance
	msg.attach(MIMEText(body, 'plain'))
 
	# open the file to be sent 
	filename = os.path.basename(file_name)
	attachment = open(file_name, "rb")
 
	# instance of MIMEBase and named as p
	p = MIMEBase('application', 'octet-stream')
 
	# To change the payload into encoded form
	p.set_payload((attachment).read())
 
	# encode into base64
	encoders.encode_base64(p)
  
	p.add_header('Content-Disposition', "attachment; filename= %s" % filename)
 
	# attach the instance 'p' to instance 'msg'
	msg.attach(p)
 
	# creates SMTP session
	s = smtplib.SMTP(SMTPSERVER)
 
	# Converts the Multipart msg into a string
	text = msg.as_string()
 
	# sending the mail
	s.sendmail(sender, receiver, text)
 
	# terminating the session
	s.quit()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Sends an email to the specified receivers using the Sykehuspartner Exchange server.")
    parser.add_argument("--sender","-s", type=str, help="Sender's email address.")
    parser.add_argument("--receiver","-r", type=str, help="Receiver's email addresses.")
    parser.add_argument("-f", "--attach",metavar='FILENAME', help="Specifies that the body argument contains a file path instead of plain text")
    args = parser.parse_args()

    path = os.path.abspath(args.attach)

    send_mail(args.attach, args.receiver, args.sender)
