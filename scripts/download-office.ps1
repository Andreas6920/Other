Do {
CLS
Write-Host "Microsoft Office 2016 Professional" -f Yellow
Write-Host "Danish or English? (y/n)" -nonewline;
$Readhost = Read-Host " " 
    Switch ($ReadHost) { 
       danish {Start "https://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/da-DK/ProfessionalRetail.img";} 
       english {Start "https://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/ProfessionalRetail.img";} 
     } } While($Readhost -notin "danish", "english")