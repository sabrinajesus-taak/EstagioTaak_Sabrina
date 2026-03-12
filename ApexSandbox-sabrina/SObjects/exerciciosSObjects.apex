public class exerciciosSObjects {
    // Duplicate Contacts
    public Boolean duplicateContacts(Contact c1, Contact c2) {
        if (c1.Email != null && c1.Phone != null && c2.Email != null && c2.Phone != null) {
            if (c1.Email == c2.Email || c1.Phone == c2.Phone) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    // Account Rating
    public void setAccountRating(Account a) {
        if (a.AnnualRevenue > 500000) {
            a.Rating = 'Hot';
        } else if (a.AnnualRevenue > 100000) {
            a.Rating = 'Warm';
        } else {
            a.Rating = 'Cold';
        }
    }

    // Contact Birthday
    public Boolean isBirthday(Contact c) {
        Date hoje = System.today();

        if (c.Birthdate.day() == hoje.day() && c.Birthdate.month() == hoje.month()) {
            return true;
        } else {
            return false;
        }
    }

    // Key Account
    public Boolean isKeyAccount(Account a) {
        if (a.Industry == 'Banking') {
            return a.AnnualRevenue >= 600000;
        } else if (a.Industry == 'Technology') {
            return a.AnnualRevenue >= 800000;
        } else if (a.Industry == 'Retail') {
            return a.AnnualRevenue >= 2000000;
        } else {
            return a.AnnualRevenue >= 500000;
        }
    }

    // Escalate Case
    public void escalateIfMeetsCriteria(Case c) {
        if ((c.Type == 'Mechanical' || c.Type == 'Electrical') && (c.Reason == 'Breakdown') && (c.Status == 'In Progress')) {
            c.IsEscalated = true;
        }
    }

    // Same Parent
    public Boolean sameParent(Contact c, Opportunity opp) {
        if (c.AccountId != null && opp.AccountId != null && c.AccountId == opp.AccountId) {
            return true;
        } else {
            return false;
        }
    }

    // Same Parent II
    public Boolean sameParent(Account acc, Contact con, Opportunity opp) {
        return acc.Id != null && con.AccountId == acc.Id && opp.AccountId == acc.Id;
    }

    // Set Parent Account
    public void setParent(Account acc, Contact con, Opportunity opp) {
        if (acc != null && acc.Id != null) {
            con.AccountId = acc.Id;
            opp.AccountId = acc.Id;
        }
    }

    // Set Parent Case
    public void linkParent(Case c1, Case c2) {
        if (c1.ContactId != null && c2.ContactId != null && c1.ContactId == c2.ContactId) {
            if (c1.CreatedDate < c2.CreatedDate) {
                c2.ParentId = c1.Id;
            } else if (c2.CreatedDate < c1.CreatedDate) {
                c1.ParentId = c2.Id;
            }
        }
    }

}