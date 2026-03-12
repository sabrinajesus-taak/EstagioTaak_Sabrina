public class exerciciosSets {
    // Union
    public Set<Integer> setUnion(Set<Integer> set1, Set<Integer> set2) {
        Set<Integer> novaLista = new Set<Integer>();
        novaLista.addAll(set1);
        novaLista.addAll(set2);
        return novaLista;
    }

    // Intersection
    public Set<Integer> setIntersection(Set<Integer> set1, Set<Integer> set2) {
        Set<Integer> novaLista = new Set<Integer>(set1);
        novaLista.retainAll(set2);
        return novaLista;
    }

    // Related Accounts
    public Set<Id> accountIds(List<Opportunity> opps) {
        Set<Id> ids = new Set<Id>();
        for (Opportunity op : opps) {
            if (op.AccountId != null) {
                ids.add(op.AccountId);
            }
        }
        return ids;
    }

    // Same Elements
    public Boolean sameElements(List<Integer> nums1, List<Integer> nums2) {
        Set<Integer> num_um = new Set<Integer>(nums1);
        Set<Integer> num_dois = new Set<Integer>(nums2);
        return num_um == num_dois;
    }

    // Duplicate Integers
    public Boolean containsDuplicates(List<Integer> nums) {
        if (nums == null || nums.size() <= 1) {
            return false;
        }
        Set<Integer> numerosVistos = new Set<Integer>();
        for (Integer n : nums) {
            if (numerosVistos.contains(n)) {
                return true;
            }
            numerosVistos.add(n);
        }
        return false;
    }

    // Contacts De-duplicator
    public static List<Contact> ContactDeduplicator(List<Contact> contacts) {
        List<Contact> contatosUnicos = new List<Contact>();
        Set<String> emailsVistos = new Set<String>();
        if (contacts == null) {
            return contatosUnicos;
        }
        for (Contact cont : contacts) {
            String emailParaComparar = '';
            if (cont.Email != null) {
                emailParaComparar = cont.Email.toLowerCase();
            }
            if (!emailsVistos.contains(emailParaComparar)) {
                contatosUnicos.add(cont);
                emailsVistos.add(emailParaComparar);
            }
        }
        return contatosUnicos;
    }

}