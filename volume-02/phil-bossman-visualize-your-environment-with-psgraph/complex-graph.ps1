graph WebSiteMap {
    node 'External' @{shape='oval'}

    subgraph DC1 -Attributes @{label='Datacenter-1'} {
        node 'loadbalancer1' @{shape='oval'}
        rank 'Web-1A','Web-1B'
        node 'Web-1A','Web-1B' @{shape='rect'}
        edge 'loadbalancer1' 'Web-1A','Web-1B'
    }
    edge 'External' 'loadbalancer1'

    subgraph DC2 -Attributes @{label='Datacenter-2';style='filled';fillcolor='lightgrey'} {

        node 'loadbalancer2' @{shape='oval';style='filled';color='white'}
        rank 'Web-2A','Web-2B'
        node 'Web-2A','Web-2B' @{shape='rect';style='filled';color='white'}
        edge 'loadbalancer2' 'Web-2A','Web-2B'
    }
    edge 'External' 'loadbalancer2'

    node 'DB1' @{shape='cylinder';label='Prod-DB'}
    edge 'Web-1A','Web-1B' 'DB1'

    node 'DB2' @{shape='cylinder';label='OffSite-DB'}
    edge 'Web-2A','Web-2B' 'DB2'

    rank 'DB1','DB2'
    edge 'DB1' 'DB2' @{label='replication'}
    edge 'DB2' 'DB1'

} | Export-PSGraph -ShowGraph