import React, { useEffect, useState, useRef } from 'react';
import { api } from '../../api';
import Table from '../../components/Table';
import * as Dialog from '@radix-ui/react-dialog';
import * as DropdownMenu from '@radix-ui/react-dropdown-menu';
import * as Toast from '@radix-ui/react-toast';

const ROLES = ['admin', 'vendor', 'rider', 'customer'];

export default function Users() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [selectedUser, setSelectedUser] = useState(null);
  const [dialogType, setDialogType] = useState(null); // 'block' | 'delete' | 'role'
  const [dialogOpen, setDialogOpen] = useState(false);
  const [actionLoading, setActionLoading] = useState(false);
  const [search, setSearch] = useState('');
  const [roleFilter, setRoleFilter] = useState('');
  const [toastOpen, setToastOpen] = useState(false);
  const [toastMsg, setToastMsg] = useState('');
  const searchTimeout = useRef();

  const fetchUsers = async (searchTerm = '', role = '') => {
    setLoading(true);
    setError('');
    try {
      let url = '/admin/users';
      const params = [];
      if (searchTerm) params.push(`search=${encodeURIComponent(searchTerm)}`);
      if (role) params.push(`role=${encodeURIComponent(role)}`);
      if (params.length) url += `?${params.join('&')}`;
      const data = await api.get(url);
      setUsers(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchUsers(); }, []);

  // Real-time search (debounced)
  useEffect(() => {
    if (searchTimeout.current) clearTimeout(searchTimeout.current);
    searchTimeout.current = setTimeout(() => {
      fetchUsers(search, roleFilter);
    }, 400);
    return () => clearTimeout(searchTimeout.current);
  }, [search, roleFilter]);

  const handleBlock = (user) => {
    setSelectedUser(user);
    setDialogType('block');
    setDialogOpen(true);
  };
  const handleDelete = (user) => {
    setSelectedUser(user);
    setDialogType('delete');
    setDialogOpen(true);
  };
  const handleRole = (user) => {
    setSelectedUser(user);
    setDialogType('role');
    setDialogOpen(true);
  };

  const confirmAction = async (roleValue) => {
    if (!selectedUser) return;
    setActionLoading(true);
    try {
      if (dialogType === 'block') {
        if (selectedUser.isActive) {
          await api.patch(`/admin/users/${selectedUser._id}/block`);
          setToastMsg('User blocked successfully');
        } else {
          await api.patch(`/admin/users/${selectedUser._id}/activate`);
          setToastMsg('User unblocked successfully');
        }
      } else if (dialogType === 'delete') {
        await api.del(`/admin/users/${selectedUser._id}`);
        setToastMsg('User deleted successfully');
      } else if (dialogType === 'role') {
        await api.patch(`/admin/users/${selectedUser._id}/role`, { role: roleValue });
        setToastMsg('User role updated');
      }
      setDialogOpen(false);
      setToastOpen(true);
      fetchUsers(search, roleFilter);
    } catch (err) {
      setToastMsg(err.message);
      setToastOpen(true);
    } finally {
      setActionLoading(false);
    }
  };

  const columns = [
    { key: 'name', title: 'Name' },
    { key: 'email', title: 'Email' },
    { key: 'role', title: 'Role', render: u => (
      <DropdownMenu.Root>
        <DropdownMenu.Trigger asChild>
          <button className="px-2 py-1 rounded bg-gray-100 hover:bg-gray-200 text-xs font-semibold border border-border">
            {u.role}
          </button>
        </DropdownMenu.Trigger>
        <DropdownMenu.Content className="bg-surface border border-border rounded shadow-lg p-1">
          {ROLES.filter(r => r !== u.role).map(role => (
            <DropdownMenu.Item key={role} className="px-3 py-1 text-sm hover:bg-primary hover:text-white rounded cursor-pointer" onSelect={() => { setSelectedUser(u); setDialogType('role'); setDialogOpen(true); confirmAction(role); }}>
              {role}
            </DropdownMenu.Item>
          ))}
        </DropdownMenu.Content>
      </DropdownMenu.Root>
    ) },
    { key: 'isActive', title: 'Status', render: u => (
      u.isActive
        ? <span className="text-success font-semibold">Active</span>
        : <span className="text-danger font-semibold">Blocked</span>
    ) },
    { key: 'actions', title: 'Actions', render: u => (
      <div className="flex gap-2">
        <button
          className={`text-xs px-2 py-1 rounded ${u.isActive ? 'bg-danger text-white' : 'bg-success text-white'}`}
          onClick={() => handleBlock(u)}
        >
          {u.isActive ? 'Block' : 'Unblock'}
        </button>
        <button className="text-xs bg-danger text-white px-2 py-1 rounded" onClick={() => handleDelete(u)}>Delete</button>
      </div>
    )},
  ];

  const data = users.map(u => ({ ...u }));

  return (
    <Toast.Provider swipeDirection="right">
      <div className="min-h-screen bg-bg flex items-center justify-center">
        <div className="max-w-5xl w-full bg-surface rounded-xl shadow-lg p-8 border border-border">
          <h1 className="text-3xl font-bold mb-6 text-primary">User Management</h1>
          <div className="mb-6 flex gap-2 items-center">
            <input
              type="text"
              className="flex-1 border border-border rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-primary bg-bg"
              placeholder="Search by name, email, or phone..."
              value={search}
              onChange={e => setSearch(e.target.value)}
            />
            <select
              className="border border-border rounded px-3 py-2 bg-bg focus:outline-none focus:ring-2 focus:ring-primary"
              value={roleFilter}
              onChange={e => setRoleFilter(e.target.value)}
            >
              <option value="">All Roles</option>
              {ROLES.map(role => <option key={role} value={role}>{role.charAt(0).toUpperCase() + role.slice(1)}</option>)}
            </select>
          </div>
          <Table columns={columns} data={data} loading={loading} error={error} />
          <Dialog.Root open={dialogOpen} onOpenChange={setDialogOpen}>
            <Dialog.Portal>
              <Dialog.Overlay className="fixed inset-0 bg-black/30 z-40" />
              <Dialog.Content className="fixed z-50 left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 bg-surface p-6 rounded-xl shadow-lg border border-border w-full max-w-sm">
                <Dialog.Title className="text-lg font-bold mb-2">Confirm {dialogType === 'block' ? 'Block' : dialogType === 'delete' ? 'Delete' : 'Change Role'}</Dialog.Title>
                <Dialog.Description className="mb-4">
                  {dialogType === 'block' && `Are you sure you want to block this user?`}
                  {dialogType === 'delete' && 'Are you sure you want to delete this user?'}
                  {dialogType === 'role' && `Are you sure you want to change this user's role?`}
                </Dialog.Description>
                <div className="flex gap-2 justify-end">
                  <Dialog.Close asChild>
                    <button className="px-4 py-2 rounded bg-gray-200 hover:bg-gray-300" disabled={actionLoading}>Cancel</button>
                  </Dialog.Close>
                  <button className="px-4 py-2 rounded bg-primary text-white hover:bg-primary-dark" onClick={() => confirmAction(dialogType === 'role' ? selectedUser?.role : undefined)} disabled={actionLoading}>
                    {actionLoading ? 'Processing...' : 'Confirm'}
                  </button>
                </div>
              </Dialog.Content>
            </Dialog.Portal>
          </Dialog.Root>
        </div>
        <Toast.Root open={toastOpen} onOpenChange={setToastOpen} className="fixed bottom-6 right-6 bg-surface border border-border rounded shadow-lg px-6 py-3 text-sm font-medium text-gray-900 z-50">
          {toastMsg}
        </Toast.Root>
        <Toast.Viewport className="fixed bottom-0 right-0 flex flex-col p-6 gap-2 w-96 max-w-full z-50" />
      </div>
    </Toast.Provider>
  );
} 